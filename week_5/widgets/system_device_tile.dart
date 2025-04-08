import 'dart:async'; // 비동기 작업을 위한 dart:async 라이브러리를 import합니다.

import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위한 flutter/material.dart 라이브러리를 import합니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리를 import합니다.

// 시스템에 연결된 블루투스 장치를 표시하는 타일 위젯입니다.
class SystemDeviceTile extends StatefulWidget {
  final BluetoothDevice device; // 표시할 블루투스 장치입니다.
  final VoidCallback onOpen; // 'OPEN' 버튼을 눌렀을 때 실행할 콜백 함수입니다.
  final VoidCallback onConnect; // 'CONNECT' 버튼을 눌렀을 때 실행할 콜백 함수입니다.

  const SystemDeviceTile({
    required this.device,
    required this.onOpen,
    required this.onConnect,
    Key? key,
  }) : super(key: key);

  @override
  State<SystemDeviceTile> createState() => _SystemDeviceTileState();
}

class _SystemDeviceTileState extends State<SystemDeviceTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected; // 장치의 연결 상태를 저장합니다.

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription; // 연결 상태 스트림 구독입니다.

  @override
  void initState() {
    super.initState();

    // 장치의 연결 상태 스트림을 구독하고 상태를 업데이트합니다.
    _connectionStateSubscription = widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });
  }

  @override
  void dispose() {
    // 스트림 구독을 취소합니다.
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  // 장치가 연결되었는지 여부를 반환합니다.
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.platformName), // 장치 이름을 표시합니다.
      subtitle: Text(widget.device.remoteId.str), // 장치 ID를 문자열로 변환하여 표시합니다.
      trailing: ElevatedButton(
        child: isConnected ? const Text('OPEN') : const Text('CONNECT'), // 연결 상태에 따라 버튼 텍스트를 설정합니다.
        onPressed: isConnected ? widget.onOpen : widget.onConnect, // 연결 상태에 따라 다른 콜백 함수를 실행합니다.
      ),
    );
  }
}