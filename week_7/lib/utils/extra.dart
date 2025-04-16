import 'utils.dart'; // 유틸리티 함수들을 import합니다.

import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리를 import합니다.

// 연결 상태를 관리하는 전역 맵입니다. DeviceIdentifier를 키로 사용하고, StreamControllerReemit<bool>을 값으로 사용합니다.
final Map<DeviceIdentifier, StreamControllerReemit<bool>> _cglobal = {};
// 연결 해제 상태를 관리하는 전역 맵입니다. DeviceIdentifier를 키로 사용하고, StreamControllerReemit<bool>을 값으로 사용합니다.
final Map<DeviceIdentifier, StreamControllerReemit<bool>> _dglobal = {};

/// connect & disconnect + update stream 확장 함수
extension Extra on BluetoothDevice {
  // 연결 상태 스트림을 편리하게 가져오는 getter입니다.
  StreamControllerReemit<bool> get _cstream {
    _cglobal[remoteId] ??= StreamControllerReemit(initialValue: false); // remoteId에 해당하는 스트림이 없으면 새로 생성합니다.
    return _cglobal[remoteId]!; // remoteId에 해당하는 스트림을 반환합니다.
  }

  // 연결 해제 상태 스트림을 편리하게 가져오는 getter입니다.
  StreamControllerReemit<bool> get _dstream {
    _dglobal[remoteId] ??= StreamControllerReemit(initialValue: false); // remoteId에 해당하는 스트림이 없으면 새로 생성합니다.
    return _dglobal[remoteId]!; // remoteId에 해당하는 스트림을 반환합니다.
  }

  // 연결 중 상태 스트림을 가져오는 getter입니다.
  Stream<bool> get isConnecting {
    return _cstream.stream; // 연결 상태 스트림을 반환합니다.
  }

  // 연결 해제 중 상태 스트림을 가져오는 getter입니다.
  Stream<bool> get isDisconnecting {
    return _dstream.stream; // 연결 해제 상태 스트림을 반환합니다.
  }

  // 연결하고 스트림을 업데이트하는 함수입니다.
  Future<void> connectAndUpdateStream() async {
    _cstream.add(true); // 연결 시작 상태를 스트림에 추가합니다.
    try {
      await connect(mtu: null); // 장치에 연결합니다.
    } finally {
      _cstream.add(false); // 연결 완료 상태를 스트림에 추가합니다.
    }
  }

  // 연결을 해제하고 스트림을 업데이트하는 함수입니다.
  Future<void> disconnectAndUpdateStream({bool queue = true}) async {
    _dstream.add(true); // 연결 해제 시작 상태를 스트림에 추가합니다.
    try {
      await disconnect(queue: queue); // 장치 연결을 해제합니다.
    } finally {
      _dstream.add(false); // 연결 해제 완료 상태를 스트림에 추가합니다.
    }
  }
}