import 'dart:async'; // 비동기 작업을 위한 dart:async 라이브러리를 import합니다.

import 'package:flutter/material.dart'; // Material 디자인 위젯을 사용하기 위한 flutter/material.dart 라이브러리를 import합니다.
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Flutter Blue Plus 라이브러리를 import합니다.

// 스캔 결과를 표시하는 타일 위젯입니다.
class ScanResultTile extends StatefulWidget {
  const ScanResultTile({Key? key, required this.result, this.onTap}) : super(key: key);

  final ScanResult result; // 스캔 결과입니다.
  final VoidCallback? onTap; // 타일을 탭했을 때 실행할 콜백 함수입니다.

  @override
  State<ScanResultTile> createState() => _ScanResultTileState();
}



class _ScanResultTileState extends State<ScanResultTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected; // 연결 상태를 저장합니다.

  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription; // 연결 상태 스트림 구독입니다.

  @override
  void initState() {
    super.initState();

    // 장치의 연결 상태 스트림을 구독하고 상태를 업데이트합니다.
    _connectionStateSubscription = widget.result.device.connectionState.listen((state) {
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

  // 바이트 배열을 보기 좋은 16진수 문자열로 변환하는 함수입니다.
  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]';
  }

  // 제조업체 데이터를 보기 좋게 문자열로 변환하는 함수입니다.
  String getNiceManufacturerData(List<List<int>> data) {
    return data.map((val) => '${getNiceHexArray(val)}').join(', ').toUpperCase();
  }

  // 서비스 데이터를 보기 좋게 문자열로 변환하는 함수입니다.
  String getNiceServiceData(Map<Guid, List<int>> data) {
    return data.entries.map((v) => '${v.key}: ${getNiceHexArray(v.value)}').join(', ').toUpperCase();
  }

  // 서비스 UUID 목록을 보기 좋게 문자열로 변환하는 함수입니다.
  String getNiceServiceUuids(List<Guid> serviceUuids) {
    return serviceUuids.join(', ').toUpperCase();
  }

  // 장치가 연결되었는지 여부를 반환합니다.
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  // 타일 제목을 빌드하는 함수입니다.
  Widget _buildTitle(BuildContext context) {
    if (widget.result.device.platformName.isNotEmpty) {
      // 장치 이름이 있는 경우 이름과 ID를 표시합니다.
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.result.device.platformName,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.result.device.remoteId.str,
            style: Theme.of(context).textTheme.bodySmall,
          )
        ],
      );
    } else {
      // 장치 이름이 없는 경우 ID만 표시합니다.
      return Text(widget.result.device.remoteId.str);
    }
  }


  // 연결된 버튼을 빌드하는 함수입니다.
  Widget _buildConnectButton(BuildContext context) {
    return ElevatedButton(
      child: isConnected ? const Text('OPEN') : const Text('CONNECT'), // 연결 상태에 따라 버튼 텍스트를 설정합니다.
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      onPressed: (widget.result.advertisementData.connectable) ? widget.onTap : null, // 연결 가능 여부에 따라 콜백 함수를 실행합니다.
    );
  }

  // 광고 데이터를 표시하는 행을 빌드하는 함수입니다.
  Widget _buildAdvRow(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.apply(color: Colors.black),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var adv = widget.result.advertisementData; // 광고 데이터를 가져옵니다.
    return ExpansionTile(
      title: _buildTitle(context), // 타일 제목을 설정합니다.
      leading: Text(widget.result.rssi.toString()), // RSSI를 표시합니다.
      trailing: _buildConnectButton(context), // 연결 버튼을 표시합니다.
      children: <Widget>[
        // 광고 데이터가 있는 경우 해당 데이터를 표시합니다.
        if (adv.advName.isNotEmpty) _buildAdvRow(context, 'Name', adv.advName),
        if (adv.txPowerLevel != null) _buildAdvRow(context, 'Tx Power Level', '${adv.txPowerLevel}'),
        if ((adv.appearance ?? 0) > 0) _buildAdvRow(context, 'Appearance', '0x${adv.appearance!.toRadixString(16)}'),
        if (adv.msd.isNotEmpty) _buildAdvRow(context, 'Manufacturer Data', getNiceManufacturerData(adv.msd)),
        if (adv.serviceUuids.isNotEmpty) _buildAdvRow(context, 'Service UUIDs', getNiceServiceUuids(adv.serviceUuids)),
        if (adv.serviceData.isNotEmpty) _buildAdvRow(context, 'Service Data', getNiceServiceData(adv.serviceData)),
      ],
    );
  }
}