import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import "characteristic_tile.dart"; // 특성 타일 위젯을 import합니다.

// 블루투스 서비스 타일을 나타내는 위젯입니다.
class ServiceTile extends StatelessWidget {
  final BluetoothService service; // 표시할 블루투스 서비스입니다.
  final List<CharacteristicTile> characteristicTiles; // 서비스에 포함된 특성 타일 목록입니다.

  const ServiceTile({Key? key, required this.service, required this.characteristicTiles}) : super(key: key);

  // 서비스 UUID를 표시하는 위젯을 빌드합니다.
  Widget buildUuid(BuildContext context) {
    String uuid = '0x${service.uuid.str.toUpperCase()}'; // UUID를 문자열로 변환하고 대문자로 변경합니다.
    return Text(uuid, style: TextStyle(fontSize: 13)); // UUID를 텍스트 위젯으로 반환합니다.
  }

  @override
  Widget build(BuildContext context) {
    // 특성 타일이 비어있지 않으면 확장 가능한 타일을 표시하고, 비어있으면 일반 리스트 타일을 표시합니다.
    return characteristicTiles.isNotEmpty
        ? ExpansionTile( // 특성 타일이 있는 경우 확장 가능한 타일을 사용합니다.
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Service', style: TextStyle(color: Colors.blue)), // 서비스 제목을 표시합니다.
          buildUuid(context), // 서비스 UUID를 표시합니다.
        ],
      ),
      children: characteristicTiles, // 특성 타일 목록을 자식으로 추가합니다.
    )
        : ListTile( // 특성 타일이 없는 경우 일반 리스트 타일을 사용합니다.
      title: const Text('Service'), // 서비스 제목을 표시합니다.
      subtitle: buildUuid(context), // 서비스 UUID를 표시합니다.
    );
  }
}