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
  ```
  ※ 버전 꼭 확인하기  
  6. 완료한 후, 터미널에서 캐시를 비우고 get 진행
     `flutter clean
     flutter pub get`
  7. <프로젝트 파일>\android\app\src\main\AndroidManifest.xml 실행
  8. manifest 구문 밑에 아래 코드 입력 (안드로이드 버전에 따른 권한 설정)
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
  1. 노트북으로 진행하다보니 애뮬레이터로는 한계가 보임 -> 스마트폰 활용
  2. 안드로이드 버전12부터는 권한 설정이 더 세분화되기 때문에 이를 고려하여 안드로이드 버전 13인 기기 활용 
  3. 기기를 컴퓨터와 물리적으로 연결 
  4. 프로젝트 파일을 실행
  5. 상단의 RUN 옆에 있는 Flutter Device Selection에서 디바이스 선택
  6. RUN  
  ※ 디바이스의 화면이 꺼지지 않도록 주의

## 2. 테스트 대상 설정
  ### - 에뮬레이터 설정
  1. 우측의 Device Manager 클릭
  2. 플레이스토어를 지원하는 임의의 기기 선택
  3. 실행 후 잠시 대기
  4. 스마트폰 화면 확인
  5. 예제코드 실행 후 결과 확인
  6. 이상 없음

