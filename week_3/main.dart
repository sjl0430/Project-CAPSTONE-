// Copyright 2017-2023, Charles Weinberger & Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async'; // 비동기 작업을 위한 라이브러리입니다.

import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위한 라이브러리입니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리입니다.

import 'screens/bluetooth_off_screen.dart'; // 블루투스 꺼짐 화면 위젯을 import합니다.
import 'screens/scan_screen.dart'; // 스캔 화면 위젯을 import합니다.

void main() {
  FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true); // Flutter Blue Plus의 로그 레벨을 설정합니다.
  runApp(const FlutterBlueApp()); // 앱을 실행합니다.
}

//
// 이 위젯은 어댑터 상태에 따라 BluetoothOffScreen 또는
// ScanScreen을 표시합니다.
//
class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown; // 블루투스 어댑터 상태를 저장합니다.

  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription; // 어댑터 상태 스트림 구독입니다.

  @override
  void initState() {
    super.initState();
    // 어댑터 상태 스트림을 구독하고 상태를 업데이트합니다.
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });
  }

  @override
  void dispose() {
    // 스트림 구독을 취소합니다.
    _adapterStateStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 어댑터 상태에 따라 표시할 화면을 결정합니다.
    Widget screen = _adapterState == BluetoothAdapterState.on
        ? const ScanScreen() // 블루투스가 켜져 있으면 스캔 화면을 표시합니다.
        : BluetoothOffScreen(adapterState: _adapterState); // 블루투스가 꺼져 있으면 꺼짐 화면을 표시합니다.

    return MaterialApp(
      color: Colors.lightBlue, // 앱의 기본 색상을 설정합니다.
      home: screen, // 표시할 화면을 설정합니다.
      navigatorObservers: [BluetoothAdapterStateObserver()], // 네비게이터 옵저버를 추가합니다.
    );
  }
}

//
// 이 옵저버는 블루투스가 꺼짐을 감지하고 DeviceScreen을 닫습니다.
//
class BluetoothAdapterStateObserver extends NavigatorObserver {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription; // 어댑터 상태 스트림 구독입니다.

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/DeviceScreen') {
      // 새 라우트가 푸시될 때 블루투스 상태 변경을 감지하기 시작합니다.
      _adapterStateSubscription ??= FlutterBluePlus.adapterState.listen((state) {
        if (state != BluetoothAdapterState.on) {
          // 블루투스가 꺼져 있으면 현재 라우트를 닫습니다.
          navigator?.pop();
        }
      });
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    // 라우트가 팝될 때 구독을 취소합니다.
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = null;
  }
}