## 1. 개발 환경 구축
  ### - Flutter
  1. Flutter를 설치하고 실행하기   
    <https://docs.flutter.dev/get-started/install>
  2. Zip 파일의 압축을 풀었을 떄 나온 flutter 폴더를 저장하고 싶은 위치에 이동 
  3. flutter 폴더 안의 bin 폴더까지의 위치 경로를 복사하여, 환경변수의 path에 저장 
  4. cmd로 flutter 폴더가 있는 위치에서 flutter 입력 
  5. 이후, 터미널에서 flutter doctor 명령어로 상태 확인
     
  ### - 안드로이드 스튜디오  
  1. 안드로이드 스튜디오의 setting의 plugin에서 flutter 설치, 이후 재시작 
  2. 재시작 후, New Flutter project... 
  3. 좌측에서 Flutter를 선택한 후, Sdk의 저장 경로 확인
  4. Next에서 프로젝트 이름 작성 (대문자 안 됨), 저장 경로 설정, Create


## 2. 테스트 대상 설정
  ### - 애뮬레이터 설정
  1. 스마트폰과 USB로 연결
  2. 안드로이드 스튜디오에서 디바이스를 연결한 스마트폰으로 설정
  3. RUN, 잠시 대기
  4. 스마트폰 화면 확인


## 문제 상황
  1. RUN을 시도하면, Error: Gradle task assembleDebug failed with exit code  오류 발생  
    - Tools의 Android SDK의 SDK Update Sites에서 업데이트가 되지 않은 것을 찾아 업데이트  
      -> 오류 지속  
    - Tools의 Android SDK의 SDK Tools에서 NDK 다운로드  
      ->
