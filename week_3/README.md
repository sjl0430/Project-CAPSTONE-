# 요약
1. 공식 플러그인 사이트에서 지원하는 예제로 스캔 여부 확인
2. 코드를 분석하며 학습
3. 예제 오류 및 편의성 수정
4. 프로젝트 계획 수정


## 1. 테스트 환경 설정
  ### - 플러그인 설치
  1. Android Studio (관리자 권한) 실행
  2. 터미널에 `flutter pub add flutter_blue_plus` 입력
  3. 프로젝트 파일에 있는 pupspec.yaml 파일을 실행
  4. dependencies: 구문에 flutter_blue와 permission_handler, device_info 입력
  ```
  dependencies:
    flutter:
      sdk: flutter   
    flutter_blue_plus: ^1.35.3
    permission_handler: ^11.4.0   
    device_info_plus: ^11.3.3`
  <!-- ※ 버전 꼭 확인하기  -->
  ```

  5. 완료한 후, 터미널에서 캐시를 비우고 get 진행
     `flutter clean
     flutter pub get`
  6. <프로젝트 파일>\android\app\src\main\AndroidManifest.xml 실행
  7. manifest 구문 밑에 아래 코드 입력 (안드로이드 버전에 따른 권한 설정)
```
<!-- Tell Google Play Store that your app uses Bluetooth LE Set android:required="true" if bluetooth is necessary -->
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false" />

<!-- New Bluetooth permissions in Android 12
https://developer.android.com/about/versions/12/features/bluetooth-permissions -->
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" \android:usesPermissionFlags="neverForLocation" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

<!-- legacy for Android 11 or lower -->
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" android:maxSdkVersion="30"/>

<!-- legacy for Android 9 or lower -->
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" android:maxSdkVersion="28" />
```

  ### - 에뮬레이터 변경
  1. 노트북으로 진행하다보니 에뮬레이터로는 한계가 보임 -> 스마트폰 활용
  2. 안드로이드 버전12부터는 권한 설정이 더 세분화되기 때문에 이를 고려하여 안드로이드 버전 13인 기기 활용 
  3. 기기를 컴퓨터와 물리적으로 연결 
  4. 프로젝트 파일을 실행
  5. 상단의 RUN 옆에 있는 Flutter Device Selection에서 디바이스 선택
  6. RUN  
  ※ 디바이스의 화면이 꺼지지 않도록 주의

## 2. BLE 예제 테스트
  ### - BLE 공식 플러그인에서 제공하는 예제로 테스트
  [참고](https://pub.dev/packages/flutter_blue_plus)
  1. 예제 파일 다운
  2. 실행
  3. 코드 해석
  4. 실행 중 생긴 오류 수정
  5. 재실행

## 수정 사항
[수정 전 - 우상단에 Disconnect가 있으나, 글자가 흰색이고 버튼형식도 아니어서 보기 어려움]
![무제21_20250325131706](https://github.com/user-attachments/assets/15872748-7ce7-4019-935f-11d21be7ba77)

[수정 후 - Disconnect에 붉은색 버튼을 달아줌]
![무제21_20250325131820](https://github.com/user-attachments/assets/63ca5bf9-47bc-4245-ae82-9581643b7f0e)

  ### - 그 외 
  - 연결 오류, 권한 오류 등을 수정하였으나 문제 해결에 신경쓰느라 기록을 못함..
