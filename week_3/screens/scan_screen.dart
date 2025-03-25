import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // 패키지 import
import 'device_screen.dart'; // 장치 상세 화면 위젯을 import합니다.
import '../utils/snackbar.dart'; // 스낵바 유틸리티를 import합니다.
import '../widgets/system_device_tile.dart'; // 시스템 장치 타일 위젯을 import합니다.
import '../widgets/scan_result_tile.dart'; // 스캔 결과 타일 위젯을 import합니다.
import '../utils/extra.dart'; // 추가 유틸리티 함수를 import합니다.

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = []; // 시스템에 연결된 블루투스장치 목록입니다.
  List<ScanResult> _scanResults = []; // 스캔 결과 목록입니다.
  bool _isScanning = false; // 현재 스캔 중인지 여부를 나타내는 플래그입니다.
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription; // 스캔 결과 스트림 구독입니다.
  late StreamSubscription<bool> _isScanningSubscription; // 스캔 상태 스트림 구독입니다.

  @override
  void initState() {
    super.initState();

    // 스캔 결과 스트림을 구독하고 결과를 _scanResults 목록에 업데이트합니다.
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    }, onError: (e) {
      // 스캔 중 오류가 발생하면 스낵바를 표시합니다.
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    // 스캔 상태 스트림을 구독하고 _isScanning 변수를 업데이트합니다.
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });
  }

  @override
  void dispose() {
    // 스트림 구독을 취소합니다.
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  // 스캔 시작 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onScanPressed() async {
    try {
      // 스캔을 시작합니다.
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15), // 스캔 타임아웃을 15초로 설정합니다.
      );
    } catch (e, backtrace) {
      // 스캔 시작 중 오류가 발생하면 스낵바를 표시합니다.
      Snackbar.show(
          ABC.b, prettyException("Start Scan Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }

    if (mounted) {
      setState(() {}); // UI를 업데이트합니다.
    }

    try {
      // iOS에서는 개인 정보 보호를 위해 `withServices`가 필요하며, Android에서는 무시됩니다.
      var withServices = [Guid("180f")]; // 배터리 레벨 서비스
      _systemDevices = await FlutterBluePlus.systemDevices(withServices); // 시스템에 연결된 장치 목록을 가져옵니다.
    } catch (e, backtrace) {
      // 시스템 장치 목록을 가져오는 중 오류가 발생하면 스낵바를 표시합니다.
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 스캔 중지 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan(); // 스캔을 중지합니다.
    } catch (e, backtrace) {
      // 스캔 중지 중 오류가 발생하면 스낵바를 표시합니다.
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 장치 연결 버튼을 눌렀을 때 실행되는 함수입니다.
  void onConnectPressed(BluetoothDevice device) {
    // 장치에 연결하고 스트림을 업데이트합니다.
    device.connectAndUpdateStream().catchError((e) {
      // 연결 중 오류가 발생하면 스낵바를 표시합니다.
      Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
    });
    // DeviceScreen으로 이동합니다.
    MaterialPageRoute route = MaterialPageRoute(
        builder: (context) => DeviceScreen(device: device), settings: RouteSettings(name: '/DeviceScreen'));
    Navigator.of(context).push(route);
  }

  // 새로고침 함수입니다.
  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15)); // 스캔 중이 아니면 스캔을 시작합니다.
    }
    if (mounted) {
      setState(() {}); // UI를 업데이트합니다.
    }
    return Future.delayed(Duration(milliseconds: 500)); // 500ms 지연 후 완료됩니다.
  }

  // 스캔 버튼을 빌드하는 함수입니다.
  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      // 현재 스캔 중이면 중지 버튼을 표시합니다.
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: onStopPressed,
        foregroundColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } else {
      // 스캔 중이 아니면 스캔 시작 버튼을 표시합니다.
      return FloatingActionButton(child: const Text("SCAN"), onPressed: onScanPressed);
    }
  }

  // 시스템 장치 타일 목록을 빌드하는 함수입니다.
  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
        device: d,
        onOpen: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DeviceScreen(device: d),
            settings: RouteSettings(name: '/DeviceScreen'),
          ),
        ),
        onConnect: () => onConnectPressed(d),
      ),
    )
        .toList();
  }

  // 스캔 결과 타일 목록을 빌드하는 함수입니다.
  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
        result: r,
        onTap: () => onConnectPressed(r.device),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyB, // 스낵바 키를 설정합니다.
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Devices'),
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh, // 새로고침 콜백을 설정합니다.
          child: ListView(
            children: <Widget>[
              ..._buildSystemDeviceTiles(context), // 시스템 장치 타일 목록을 추가합니다.
              ..._buildScanResultTiles(context), // 스캔 결과 타일 목록을 추가합니다.
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context), // 스캔 버튼을 추가합니다.
      ),
    );
  }
}