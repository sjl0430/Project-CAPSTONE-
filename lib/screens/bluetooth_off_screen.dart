import 'dart:io'; // 플랫폼별 처리를 위해 dart:io를 import합니다.
import 'package:flutter/foundation.dart'; // kIsWeb 상수 사용을 위해 flutter/foundation.dart를 import합니다.
import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위해 flutter/material.dart를 import합니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리를 import합니다.

import '../utils/snackbar.dart'; // 스낵바 유틸리티를 import합니다.

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.adapterState}) : super(key: key);

  final BluetoothAdapterState? adapterState; // 블루투스 어댑터 상태를 저장합니다.

  @override
  Widget build(BuildContext context) {
    // 어댑터 상태를 문자열로 변환합니다.
    String state = adapterState?.toString().split(".").last ?? 'not available';

    return ScaffoldMessenger(
      key: Snackbar.snackBarKeyA, // 스낵바 키를 설정합니다.
      child: Scaffold(
        backgroundColor: Colors.black, // 배경색을 블랙으로 설정합니다.
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // 수직 가운데 정렬
                crossAxisAlignment: CrossAxisAlignment.center, // 수평 가운데 정렬
                children: [
                  // 원형 배경의 블루투스 꺼짐 아이콘
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white10,
                    ),
                    child: const Icon(
                      Icons.bluetooth_disabled,
                      size: 140.0,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // 어댑터 상태 텍스트
                  Text(
                    'Bluetooth is $state',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                      ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // 설명 텍스트
                  Text(
                    'Please enable Bluetooth to continue using the app.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // 안드로이드 플랫폼에서만 블루투스 켜기 버튼 표시
                  if (!kIsWeb && Platform.isAndroid)
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await FlutterBluePlus.turnOn(); // 블루투스를 켭니다.
                        } catch (e, backtrace) {
                          Snackbar.show(
                            ABC.a,
                            prettyException("Error Turning On:", e),
                            success: false,
                          ); // 오류 스낵바를 표시합니다.
                          print("$e\nbacktrace: $backtrace");
                        }
                      },
                      icon: const Icon(Icons.power_settings_new, size: 28), // 전원 아이콘
                      label: const Text(
                          'Enable Bluetooth', // 버튼 텍스트
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.shade700, // 버튼 배경색
                        foregroundColor: Colors.black, // 텍스트 색상
                        padding:
                        const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0), // 둥근 테두리
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
