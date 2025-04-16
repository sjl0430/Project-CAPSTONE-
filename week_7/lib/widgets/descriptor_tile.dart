import 'dart:async'; // 비동기 작업을 위한 라이브러리입니다.
import 'dart:math'; // 난수 생성을 위한 라이브러리입니다.

import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위한 라이브러리입니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리입니다.

import "../utils/snackbar.dart"; // 스낵바 유틸리티를 import합니다.

// 블루투스 설명자 타일을 나타내는 위젯입니다.
class DescriptorTile extends StatefulWidget {
  final BluetoothDescriptor descriptor; // 표시할 블루투스 설명자입니다.

  const DescriptorTile({Key? key, required this.descriptor}) : super(key: key);

  @override
  State<DescriptorTile> createState() => _DescriptorTileState();
}

class _DescriptorTileState extends State<DescriptorTile> {
  List<int> _value = []; // 설명자의 값을 저장하는 리스트입니다.

  late StreamSubscription<List<int>> _lastValueSubscription; // 설명자의 마지막 값 스트림 구독입니다.

  @override
  void initState() {
    super.initState();
    // 설명자의 마지막 값 스트림을 구독하고 값을 업데이트합니다.
    _lastValueSubscription = widget.descriptor.lastValueStream.listen((value) {
      _value = value;
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    });
  }

  @override
  void dispose() {
    // 스트림 구독을 취소합니다.
    _lastValueSubscription.cancel();
    super.dispose();
  }

  // 설명자를 편리하게 가져오는 getter입니다.
  BluetoothDescriptor get d => widget.descriptor;

  // 랜덤 바이트 배열을 생성하는 함수입니다.
  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  // 설명자 읽기 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onReadPressed() async {
    try {
      await d.read(); // 설명자 값을 읽습니다.
      Snackbar.show(ABC.c, "Descriptor Read : Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Descriptor Read Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 설명자 쓰기 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onWritePressed() async {
    try {
      await d.write(_getRandomBytes()); // 설명자에 랜덤 바이트 배열을 씁니다.
      Snackbar.show(ABC.c, "Descriptor Write : Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Descriptor Write Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 설명자 UUID를 표시하는 위젯을 빌드합니다.
  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.descriptor.uuid.str.toUpperCase()}'; // UUID를 문자열로 변환하고 대문자로 변경합니다.
    return Text(uuid, style: TextStyle(fontSize: 13)); // UUID를 텍스트 위젯으로 반환합니다.
  }

  // 설명자 값을 표시하는 위젯을 빌드합니다.
  Widget buildValue(BuildContext context) {
    String data = _value.toString(); // 값을 문자열로 변환합니다.
    return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey)); // 값을 텍스트 위젯으로 반환합니다.
  }

  // 읽기 버튼을 빌드합니다.
  Widget buildReadButton(BuildContext context) {
    return TextButton(
      child: Text("Read"),
      onPressed: onReadPressed,
    );
  }

  // 쓰기 버튼을 빌드합니다.
  Widget buildWriteButton(BuildContext context) {
    return TextButton(
      child: Text("Write"),
      onPressed: onWritePressed,
    );
  }

  // 읽기/쓰기 버튼 행을 빌드합니다.
  Widget buildButtonRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildReadButton(context),
        buildWriteButton(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Descriptor'), // 설명자 제목을 표시합니다.
          buildUuid(context), // UUID를 표시합니다.
          buildValue(context), // 값을 표시합니다.
        ],
      ),
      subtitle: buildButtonRow(context), // 읽기/쓰기 버튼 행을 표시합니다.
    );
  }
}