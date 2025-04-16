import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// 스낵바를 구분하기 위한 열거형입니다.
enum ABC {
  a, // 스낵바 A를 나타냅니다.
  b, // 스낵바 B를 나타냅니다.
  c, // 스낵바 C를 나타냅니다.
}

// 스낵바 관련 기능을 제공하는 클래스입니다.
class Snackbar {
  // 각 스낵바의 상태를 관리하기 위한 GlobalKey입니다.
  static final snackBarKeyA = GlobalKey<ScaffoldMessengerState>();
  static final snackBarKeyB = GlobalKey<ScaffoldMessengerState>();
  static final snackBarKeyC = GlobalKey<ScaffoldMessengerState>();

  // ABC 열거형 값을 기반으로 해당 스낵바의 GlobalKey를 반환하는 함수입니다.
  static GlobalKey<ScaffoldMessengerState> getSnackbar(ABC abc) {
    switch (abc) {
      case ABC.a:
        return snackBarKeyA;
      case ABC.b:
        return snackBarKeyB;
      case ABC.c:
        return snackBarKeyC;
    }
  }

  // 스낵바를 표시하는 함수입니다.
  static show(ABC abc, String msg, {required bool success}) {
    // 성공 여부에 따라 스낵바의 색상을 설정합니다.
    final snackBar = success
        ? SnackBar(content: Text(msg), backgroundColor: Colors.blue) // 성공 시 파란색 스낵바를 표시합니다.
        : SnackBar(content: Text(msg), backgroundColor: Colors.red); // 실패 시 빨간색 스낵바를 표시합니다.

    // 기존 스낵바를 제거하고 새 스낵바를 표시합니다.
    getSnackbar(abc).currentState?.removeCurrentSnackBar();
    getSnackbar(abc).currentState?.showSnackBar(snackBar);
  }
}

// 예외를 보기 좋게 문자열로 변환하는 함수입니다.
String prettyException(String prefix, dynamic e) {
  // FlutterBluePlusException인 경우 설명을 반환합니다.
  if (e is FlutterBluePlusException) {
    return "$prefix ${e.description}";
  }
  // PlatformException인 경우 메시지를 반환합니다.
  else if (e is PlatformException) {
    return "$prefix ${e.message}";
  }
  // 그 외의 경우 toString() 결과를 반환합니다.
  return prefix + e.toString();
}