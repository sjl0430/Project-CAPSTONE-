import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_screen.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<ScanResult> _currentResults = [];
  final Map<DeviceIdentifier, ScanResult> _deviceCache = {};
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  Timer? _scanLoopTimer;
  int _scanElapsed = 0;

  int immediateThreshold = -60;
  int nearThreshold = -80;

  bool _autoRefresh = true;
  bool _isScanning = false;

  TextEditingController _searchController = TextEditingController();
  String _lastSearchQuery = '';

  void _filterResultsBySearch(String query) {
    setState(() {
      _lastSearchQuery = query;
    });
  }

  @override
  void initState() {
    super.initState();
    _subscribeScanResults();
    _startRepeatingScan();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanLoopTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Search Device"),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter device name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _filterResultsBySearch(_searchController.text);
                Navigator.of(context).pop();
              },
              child: const Text("Done", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                _searchController.clear();
                _filterResultsBySearch('');
              },
              child: const Text("Reset", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _subscribeScanResults() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (_autoRefresh) {
        for (var result in results) {
          if (result.device.name.isNotEmpty) {
            _deviceCache[result.device.id] = result;
          }
        }
        setState(() {
          _currentResults = _deviceCache.values.toList()
            ..sort((a, b) => a.rssi.compareTo(b.rssi));
        });
      }
    });
  }

  void _startRepeatingScan({Duration duration = const Duration(minutes: 1)}) {
    const scanDuration = Duration(seconds: 2);
    const pauseDuration = Duration(milliseconds: 400);
    const cycleDuration = Duration(milliseconds: 2400);
    _scanElapsed = 0;

    _scanLoopTimer?.cancel();
    _scanLoopTimer = Timer.periodic(cycleDuration, (timer) async {
      if (!_autoRefresh) {
        timer.cancel();
        return;
      }

      _scanElapsed += cycleDuration.inMilliseconds;
      if (_scanElapsed >= duration.inMilliseconds) {
        await FlutterBluePlus.stopScan();
        setState(() {
          _isScanning = false;
          _autoRefresh = false;
        });
        timer.cancel();
        return;
      }

      await FlutterBluePlus.stopScan();
      setState(() => _isScanning = false);
      await Future.delayed(pauseDuration);
      setState(() => _isScanning = true);
      await FlutterBluePlus.startScan(timeout: scanDuration);
    });
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });

    if (_autoRefresh) {
      _startRepeatingScan();
    } else {
      FlutterBluePlus.stopScan();
      setState(() => _isScanning = false);
      _scanLoopTimer?.cancel();
    }
  }

  void _openThresholdSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text("RSSI 거리 기준 설정"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("가까움 (Near) 기준:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("멀어짐", style: TextStyle(fontSize: 12)),
                        Text("가까워짐", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Slider(
                      value: nearThreshold.toDouble(),
                      min: -100,
                      max: -30,
                      divisions: 70,
                      label: "$nearThreshold",
                      onChanged: (value) {
                        int newValue = value.toInt();
                        if (newValue <= immediateThreshold) {
                          setLocalState(() {
                            nearThreshold = newValue;
                          });
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("매우 가까움 (Immediate) 기준:"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("멀어짐", style: TextStyle(fontSize: 12)),
                        Text("가까워짐", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Slider(
                      value: immediateThreshold.toDouble(),
                      min: -100,
                      max: -30,
                      divisions: 70,
                      label: "$immediateThreshold",
                      onChanged: (value) {
                        int newValue = value.toInt();
                        if (newValue >= nearThreshold) {
                          setLocalState(() {
                            immediateThreshold = newValue;
                          });
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("닫기"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      immediateThreshold = -60;
                      nearThreshold = -80;
                    });
                    setLocalState(() {});
                  },
                  child: const Text("초기화"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String getProximity(int rssi) {
    if (rssi >= immediateThreshold) return "Immediate";
    if (rssi >= nearThreshold) return "Near";
    return "Far";
  }

  Color getColorByRssi(int rssi) {
    if (rssi >= immediateThreshold) return Colors.deepOrange.shade200;
    if (rssi >= nearThreshold) return Colors.lightGreen.shade300;
    return Colors.cyan.shade200;
  }

  List<ScanResult> filterByProximity(String proximity) {
    return _currentResults.where((r) {
      bool matchesProximity = getProximity(r.rssi) == proximity;
      bool matchesSearch = r.device.name.toLowerCase().contains(_lastSearchQuery.toLowerCase());
      return matchesProximity && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final immediateDevices = filterByProximity("Immediate");
    final nearDevices = filterByProximity("Near");
    final farDevices = filterByProximity("Far");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.pink,),
            onPressed: _showSearchDialog,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_isScanning)
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.greenAccent),
                    ),
                  ),
                IconButton(
                  icon: Icon(_autoRefresh ? Icons.pause_circle_filled : Icons.play_circle_fill),
                  onPressed: _toggleAutoRefresh,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blueAccent),
            onPressed: _openThresholdSettings,
          )
        ],
      ),
      body: Column(
        children: [
          _buildZone(context, "Far", Colors.lightBlue.shade50, farDevices),
          _buildZone(context, "Near", Colors.lightGreen.shade50, nearDevices),
          _buildZone(context, "Immediate", Colors.pink.shade50, immediateDevices),        ],
      ),
    );
  }

  Widget _buildZone(BuildContext context, String label, Color color, List<ScanResult> devices) {
    return Expanded(
      child: Container(
        color: color,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Text(label,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            ),
            _buildDeviceBubbles(context, devices),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceBubbles(BuildContext context, List<ScanResult> devices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: devices.asMap().entries.map((entry) {
            int index = entry.key;
            ScanResult result = entry.value;

            double left = (index % 4) * 80.0 + 20;
            double top = 40.0 + (index ~/ 4) * 70.0;

            return Positioned(
              left: left.clamp(0.0, constraints.maxWidth - 70),
              top: top.clamp(0.0, constraints.maxHeight - 70),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DeviceScreen(device: result.device),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: getColorByRssi(result.rssi),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          result.device.name.isNotEmpty ? result.device.name : 'Unknown',
                          style: const TextStyle(fontSize: 9, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${result.rssi} dBm',
                          style: const TextStyle(fontSize: 9, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
