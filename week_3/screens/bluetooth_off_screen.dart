import 'dart:io'; // 플랫폼별 처리를 위해 dart:io를 import합니다.

import 'package:flutter/foundation.dart'; // kIsWeb 상수 사용을 위해 flutter/foundation.dart를 import합니다.
import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위해 flutter/material.dart를 import합니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리를 import합니다.

import '../utils/snackbar.dart'; // 스낵바 유틸리티를 import합니다.

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState; // 블루투스 어댑터 상태를 저장합니다.

  // 블루투스 꺼짐 아이콘을 빌드하는 함수입니다.
  Widget buildBluetoothOffIcon(BuildContext context) {
    return const Icon(
      Icons.bluetooth_disabled,
      size: 200.0,
      color: Colors.white54,
    );
  }

  // 타이틀을 빌드하는 함수입니다.
  Widget buildTitle(BuildContext context) {
    String? state = adapterState?.toString().split(".").last; // 어댑터 상태를 문자열로 변환합니다.
    return Text(
      'Bluetooth Adapter is ${state != null ? state : 'not available'}', // 어댑터 상태에 따라 타이틀을 설정합니다.
      style: Theme.of(context).primaryTextTheme.titleSmall?.copyWith(color: Colors.white),
    );
  }

  // 블루투스 켜기 버튼을 빌드하는 함수입니다.
  Widget buildTurnOnButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ElevatedButton(
        child: const Text('TURN ON'),
        onPressed: () async {
          try {
            if (!kIsWeb && Platform.isAndroid) { // 웹이 아니고 안드로이드 플랫폼인 경우에만 실행합니다.
              await FlutterBluePlus.turnOn(); // 블루투스를 켭니다.
            }
          } catch (e, backtrace) {
            Snackbar.show(ABC.a, prettyException("Error Turning On:", e), success: false); // 오류 스낵바를 표시합니다.
            print("$e");
            print("backtrace: $backtrace");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyA, // 스낵바 키를 설정합니다.
      child: Scaffold(
        backgroundColor: Colors.lightBlue, // 배경색을 설정합니다.
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildBluetoothOffIcon(context), // 블루투스 꺼짐 아이콘을 표시합니다.
              buildTitle(context), // 타이틀을 표시합니다.
              if (!kIsWeb && Platform.isAndroid) buildTurnOnButton(context), // 안드로이드 플랫폼인 경우에만 켜기 버튼을 표시합니다.
            ],
          ),
        ),
      ),
    );
  }
}