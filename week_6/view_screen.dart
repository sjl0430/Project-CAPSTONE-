import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_screen.dart';

class ViewScreen extends StatefulWidget {
  final List<ScanResult> initialResults;

  const ViewScreen({Key? key, required this.initialResults}) : super(key: key);

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  List<ScanResult> _currentResults = [];
  bool _autoRefresh = true;
  Timer? _refreshTimer;

  int immediateThreshold = -60;
  int nearThreshold = -80;



  @override
  void initState() {
    super.initState();
    _currentResults = widget.initialResults;
    _startAutoRefresh();
  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_autoRefresh) {
        setState(() {
          _currentResults.sort((a, b) => a.rssi.compareTo(b.rssi));
        });
      }
    });
  }

  void _toggleAutoRefresh() {
    setState(() {
      _autoRefresh = !_autoRefresh;
    });
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
                    // Near 설정 먼저
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

                    // Immediate 설정 나중에
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
                    setLocalState(() {}); // 슬라이더도 시각적으로 갱신
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
    if (rssi >= immediateThreshold) return Colors.tealAccent.shade400;
    if (rssi >= nearThreshold) return Colors.lightBlueAccent;
    return Colors.deepPurpleAccent.shade100;
  }

  List<ScanResult> filterByProximity(String proximity) {
    return _currentResults.where((r) => getProximity(r.rssi) == proximity).toList();
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
        title: const Text('Connected Devices'),
        actions: [
          IconButton(
            icon: Icon(_autoRefresh ? Icons.pause_circle_filled : Icons.play_circle_fill),
            onPressed: _toggleAutoRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openThresholdSettings,
          )
        ],
      ),
      body: Column(
        children: [
          _buildZone(context, "Far", Colors.deepPurple.shade100, farDevices, 0),
          _buildZone(context, "Near", Colors.indigo.shade100, nearDevices, 1),
          _buildZone(context, "Immediate", Colors.lightBlue.shade100, immediateDevices, 2),
        ],
      ),
    );
  }

  Widget _buildZone(BuildContext context, String label, Color color, List<ScanResult> devices, int index) {
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
                child: Container(
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
