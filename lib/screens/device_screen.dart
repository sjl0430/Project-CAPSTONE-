import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../widgets/service_tile.dart'; // 서비스 타일 위젯을 import합니다.
import '../widgets/characteristic_tile.dart'; // 특성 타일 위젯을 import합니다.
import '../widgets/descriptor_tile.dart'; // 설명자 타일 위젯을 import합니다.
import '../utils/snackbar.dart'; // 스낵바 유틸리티를 import합니다.
import '../utils/extra.dart'; // 추가 유틸리티 함수를 import합니다.

class DeviceScreen extends StatefulWidget {
  final BluetoothDevice device; // 연결할 블루투스 장치입니다.

  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceScreen> createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  int? _rssi; // RSSI (수신 신호 강도) 값입니다.
  int? _mtuSize; // MTU (최대 전송 단위) 크기입니다.
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected; // 연결 상태입니다.
  List<BluetoothService> _services = []; // 발견된 서비스 목록입니다.
  bool _isDiscoveringServices = false; // 서비스 검색 중인지 여부입니다.
  bool isConnecting = false; // 연결 중인지 여부입니다.
  bool isDisconnecting = false; // 연결 해제 중인지 여부입니다.

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription; // 연결 상태 스트림 구독입니다.
  late StreamSubscription<bool> _isConnectingSubscription; // 연결 중 상태 스트림 구독입니다.
  late StreamSubscription<bool> _isDisconnectingSubscription; // 연결 해제 중 상태 스트림 구독입니다.
  late StreamSubscription<int> _mtuSubscription; // MTU 크기 스트림 구독입니다.

  @override
  void initState() {
    super.initState();

    // 연결 상태 스트림을 구독하고 상태를 업데이트합니다.
    _connectionStateSubscription = widget.device.connectionState.listen((state) async {
      _connectionState = state;
      if (state == BluetoothConnectionState.connected) {
        _services = []; // 연결되면 서비스를 다시 검색해야 합니다.
      }
      if (state == BluetoothConnectionState.connected && _rssi == null) {
        _rssi = await widget.device.readRssi(); // 연결되면 RSSI를 읽어옵니다.
      }
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });

    // MTU 크기 스트림을 구독하고 크기를 업데이트합니다.
    _mtuSubscription = widget.device.mtu.listen((value) {
      _mtuSize = value;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });

    // 연결 중 상태 스트림을 구독하고 상태를 업데이트합니다.
    _isConnectingSubscription = widget.device.isConnecting.listen((value) {
      isConnecting = value;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });

    // 연결 해제 중 상태 스트림을 구독하고 상태를 업데이트합니다.
    _isDisconnectingSubscription = widget.device.isDisconnecting.listen((value) {
      isDisconnecting = value;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });
  }

  @override
  void dispose() {
    // 스트림 구독을 취소합니다.
    _connectionStateSubscription.cancel();
    _mtuSubscription.cancel();
    _isConnectingSubscription.cancel();
    _isDisconnectingSubscription.cancel();
    super.dispose();
  }

  // 연결되었는지 여부를 반환합니다.
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  // 연결 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onConnectPressed() async {
    try {
      await widget.device.connectAndUpdateStream(); // 장치에 연결합니다.
      Snackbar.show(ABC.c, "Connect: Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      if (e is FlutterBluePlusException && e.code == FbpErrorCode.connectionCanceled.index) {
        // 사용자가 연결을 취소한 경우 무시합니다.
      } else {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false); // 오류 스낵바를 표시합니다.
        print(e);
        print("backtrace: $backtrace");
      }
    }
  }

  // 연결 취소 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onCancelPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(queue: false); // 연결을 취소합니다.
      Snackbar.show(ABC.c, "Cancel: Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Cancel Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print("$e");
      print("backtrace: $backtrace");
    }
  }

  // 연결 해제 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onDisconnectPressed() async {
    try {
      await widget.device.disconnectAndUpdateStream(); // 장치 연결을 해제합니다.
      Snackbar.show(ABC.c, "Disconnect: Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Disconnect Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print("$e backtrace: $backtrace");
    }
  }

  // 서비스 검색 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onDiscoverServicesPressed() async {
    if (mounted) {
      setState(() {
        _isDiscoveringServices = true; // 서비스 검색 중 상태로 설정합니다.
      });
    }
    try {
      _services = await widget.device.discoverServices(); // 서비스를 검색합니다.
      Snackbar.show(ABC.c, "Discover Services: Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Discover Services Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
    if (mounted) {
      setState(() {
        _isDiscoveringServices = false; // 서비스 검색 완료 상태로 설정합니다.
      });
    }
  }

  // MTU 요청 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onRequestMtuPressed() async {
    try {
      await widget.device.requestMtu(223, predelay: 0); // MTU 크기를 요청합니다.
      Snackbar.show(ABC.c, "Request Mtu: Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Change Mtu Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 서비스 타일 목록을 빌드하는 함수입니다.
  List<Widget> _buildServiceTiles(BuildContext context, BluetoothDevice d) {
    return _services
        .map(
          (s) => ServiceTile(
        service: s,
        characteristicTiles: s.characteristics.map((c) => _buildCharacteristicTile(c)).toList(), // 특성 타일 목록을 빌드합니다.
      ),
    )
        .toList();
  }

  // 특성 타일을 빌드하는 함수입니다.
  CharacteristicTile _buildCharacteristicTile(BluetoothCharacteristic c) {
    return CharacteristicTile(
      characteristic: c,
      descriptorTiles: c.descriptors.map((d) => DescriptorTile(descriptor: d)).toList(), // 설명자 타일 목록을 빌드합니다.
    );
  }
  // 로딩 스피너를 빌드하는 함수입니다.
  Widget buildSpinner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: CircularProgressIndicator(
          backgroundColor: Colors.black12,
          color: Colors.black26,
        ),
      ),
    );
  }

  // 원격 장치 ID를 표시하는 위젯을 빌드하는 함수입니다.
  Widget buildRemoteId(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text('${widget.device.remoteId}'),
    );
  }

  // RSSI 타일을 빌드하는 함수입니다.
  Widget buildRssiTile(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isConnected ? const Icon(Icons.bluetooth_connected) : const Icon(Icons.bluetooth_disabled), // 연결 상태에 따라 아이콘을 표시합니다.
        Text(((isConnected && _rssi != null) ? '${_rssi!} dBm' : ''), style: Theme.of(context).textTheme.bodySmall) // RSSI 값을 표시합니다.
      ],
    );
  }

  // 서비스 검색 버튼을 빌드하는 함수입니다.
  Widget buildGetServices(BuildContext context) {
    return IndexedStack(
      index: (_isDiscoveringServices) ? 1 : 0, // 서비스 검색 중이면 로딩 스피너를 표시합니다.
      children: <Widget>[
        TextButton(
          child: const Text("Get Services"),
          onPressed: onDiscoverServicesPressed,
        ),
        const IconButton(
          icon: SizedBox(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.grey),
            ),
            width: 18.0,
            height: 18.0,
          ),
          onPressed: null,
        )
      ],
    );
  }

  // MTU 타일을 빌드하는 함수입니다.
  Widget buildMtuTile(BuildContext context) {
    return ListTile(
        title: const Text('MTU Size'),
        subtitle: Text('$_mtuSize bytes'), // MTU 크기를 표시합니다.
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onRequestMtuPressed, // MTU 요청 버튼을 표시합니다.
        ));
  }

  // 연결할 버튼을 빌드하는 함수입니다.
  Widget buildConnectButton(BuildContext context) {
    return Row(children: [
      if (isConnecting || isDisconnecting) buildSpinner(context), // 연결 또는 연결 해제 중이면 로딩 스피너를 표시합니다.
      TextButton(
          onPressed: isConnecting ? onCancelPressed : (isConnected ? onDisconnectPressed : onConnectPressed), // 연결 상태에 따라 버튼 동작을 설정합니다.
          style: TextButton.styleFrom(
            backgroundColor: isConnected ? Colors.red : Colors.black, // 연결 상태에 따라 배경색 설정
            foregroundColor: Colors.white,
          ),
          child: Text(
            isConnecting ? "CANCEL" : (isConnected ? "DISCONNECT" : "CONNECT"), // 버튼 텍스트를 설정합니다.
            style: Theme.of(context).primaryTextTheme.labelLarge?.copyWith(color: Colors.white),
          ))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyC, // 스낵바 키를 설정합니다.
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.platformName), // 앱바 제목을 설정합니다.
          actions: [buildConnectButton(context)], // 앱바 액션을 설정합니다.
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildRemoteId(context), // 원격 장치 ID를 표시합니다.
              ListTile(
                leading: buildRssiTile(context), // RSSI 타일을 표시합니다.
                title: Text('Device is ${_connectionState.toString().split('.')[1]}.'), // 연결 상태를 표시합니다.
                trailing: buildGetServices(context), // 서비스 검색 버튼을 표시합니다.
              ),
              buildMtuTile(context), // MTU 타일을 표시합니다.
              ..._buildServiceTiles(context, widget.device), // 서비스 타일 목록을 표시합니다.
            ],
          ),
        ),
      ),
    );
  }
}