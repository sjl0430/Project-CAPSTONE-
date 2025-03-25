import 'dart:async'; // 비동기 작업을 위한 라이브러리입니다.
import 'dart:math'; // 난수 생성을 위한 라이브러리입니다.
import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위한 라이브러리입니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리입니다.
import "../utils/snackbar.dart"; // 스낵바 유틸리티를 import합니다.
import "descriptor_tile.dart"; // 설명자 타일 위젯을 import합니다.

// 블루투스 특성 타일을 나타내는 위젯입니다.
class CharacteristicTile extends StatefulWidget {
  final BluetoothCharacteristic characteristic; // 표시할 블루투스 특성입니다.
  final List<DescriptorTile> descriptorTiles; // 특성에 포함된 설명자 타일 목록입니다.

  const CharacteristicTile({Key? key, required this.characteristic, required this.descriptorTiles}) : super(key: key);

  @override
  State<CharacteristicTile> createState() => _CharacteristicTileState();
}

class _CharacteristicTileState extends State<CharacteristicTile> {
  List<int> _value = []; // 특성의 값을 저장하는 리스트입니다.

  late StreamSubscription<List<int>> _lastValueSubscription; // 특성의 마지막 값 스트림 구독입니다.

  @override
  void initState() {
    super.initState();
    // 특성의 마지막 값 스트림을 구독하고 값을 업데이트합니다.
    _lastValueSubscription = widget.characteristic.lastValueStream.listen((value) {
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

  // 특성을 편리하게 가져오는 getter입니다.
  BluetoothCharacteristic get c => widget.characteristic;

  // 랜덤 바이트 배열을 생성하는 함수입니다.
  List<int> _getRandomBytes() {
    final math = Random();
    return [math.nextInt(255), math.nextInt(255), math.nextInt(255), math.nextInt(255)];
  }

  // 읽기 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onReadPressed() async {
    try {
      await c.read(); // 특성 값을 읽습니다.
      Snackbar.show(ABC.c, "Read: Success", success: true); // 성공 스낵바를 표시합니다.
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Read Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 쓰기 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onWritePressed() async {
    try {
      await c.write(_getRandomBytes(), withoutResponse: c.properties.writeWithoutResponse); // 특성에 랜덤 바이트 배열을 씁니다.
      Snackbar.show(ABC.c, "Write: Success", success: true); // 성공 스낵바를 표시합니다.
      if (c.properties.read) {
        await c.read(); // 쓰기 후 읽기 속성이 활성화되어 있으면 값을 다시 읽습니다.
      }
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Write Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 구독/구독 취소 버튼을 눌렀을 때 실행되는 함수입니다.
  Future onSubscribePressed() async {
    try {
      String op = c.isNotifying == false ? "Subscribe" : "Unubscribe"; // 현재 구독 상태에 따라 동작을 설정합니다.
      await c.setNotifyValue(c.isNotifying == false); // 구독 상태를 변경합니다.
      Snackbar.show(ABC.c, "$op : Success", success: true); // 성공 스낵바를 표시합니다.
      if (c.properties.read) {
        await c.read(); // 구독 후 읽기 속성이 활성화되어 있으면 값을 다시 읽습니다.
      }
      if (mounted) {
        setState(() {}); // UI를 업데이트합니다.
      }
    } catch (e, backtrace) {
      Snackbar.show(ABC.c, prettyException("Subscribe Error:", e), success: false); // 오류 스낵바를 표시합니다.
      print(e);
      print("backtrace: $backtrace");
    }
  }

  // 특성 UUID를 표시하는 위젯을 빌드합니다.
  Widget buildUuid(BuildContext context) {
    String uuid = '0x${widget.characteristic.uuid.str.toUpperCase()}'; // UUID를 문자열로 변환하고 대문자로 변경합니다.
    return Text(uuid, style: TextStyle(fontSize: 13)); // UUID를 텍스트 위젯으로 반환합니다.
  }

  // 특성 값을 표시하는 위젯을 빌드합니다.
  Widget buildValue(BuildContext context) {
    String data = _value.toString(); // 값을 문자열로 변환합니다.
    return Text(data, style: TextStyle(fontSize: 13, color: Colors.grey)); // 값을 텍스트 위젯으로 반환합니다.
  }

  // 읽기 버튼을 빌드합니다.
  Widget buildReadButton(BuildContext context) {
    return TextButton(
        child: Text("Read"),
        onPressed: () async {
          await onReadPressed(); // 읽기 동작을 수행합니다.
          if (mounted) {
            setState(() {}); // UI를 업데이트합니다.
          }
        });
  }

  // 쓰기 버튼을 빌드합니다.
  Widget buildWriteButton(BuildContext context) {
    bool withoutResp = widget.characteristic.properties.writeWithoutResponse; // 응답 없는 쓰기 속성을 확인합니다.
    return TextButton(
        child: Text(withoutResp ? "WriteNoResp" : "Write"), // 응답 없는 쓰기 여부에 따라 버튼 텍스트를 설정합니다.
        onPressed: () async {
          await onWritePressed(); // 쓰기 동작을 수행합니다.
          if (mounted) {
            setState(() {}); // UI를 업데이트합니다.
          }
        });
  }

  // 구독/구독 취소 버튼을 빌드합니다.
  Widget buildSubscribeButton(BuildContext context) {
    bool isNotifying = widget.characteristic.isNotifying; // 현재 구독 상태를 확인합니다.
    return TextButton(
        child: Text(isNotifying ? "Unsubscribe" : "Subscribe"), // 구독 상태에 따라 버튼 텍스트를 설정합니다.
        onPressed: () async {
          await onSubscribePressed(); // 구독/구독 취소 동작을 수행합니다.
          if (mounted) {
            setState(() {}); // UI를 업데이트합니다.
          }
        });
  }

  // 버튼 행을 빌드합니다.
  Widget buildButtonRow(BuildContext context) {
    bool read = widget.characteristic.properties.read; // 읽기 속성을 확인합니다.
    bool write = widget.characteristic.properties.write; // 쓰기 속성을 확인합니다.
    bool notify = widget.characteristic.properties.notify; // 알림 속성을 확인합니다.
    bool indicate = widget.characteristic.properties.indicate; // 표시 속성을 확인합니다.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (read) buildReadButton(context), // 읽기 속성이 활성화되어 있으면 읽기 버튼을 표시합니다.
        if (write) buildWriteButton(context), // 쓰기 속성이 활성화되어 있으면 쓰기 버튼을 표시합니다.
        if (notify || indicate) buildSubscribeButton(context), // 알림 또는 표시 속성이 활성화되어 있으면 구독/구독 취소 버튼을 표시합니다.
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Characteristic'), // 특성 제목을 표시합니다.
            buildUuid(context), // UUID를 표시합니다.
            buildValue(context), // 값을 표시합니다.
          ],
        ),
        subtitle: buildButtonRow(context), // 버튼 행을 표시합니다.
        contentPadding: const EdgeInsets.all(0.0),
      ),
      children: widget.descriptorTiles, // 설명자 타일 목록을 표시합니다.
    );
  }
}