## 1. 오류 수정 및 기능 조정
  1. 갱신이 안 되는 오류 수정  
     - view에서 리스트를 출력하는 형식인 것을 그냥 직접 scan하는 걸로 변경  
     - 이에 따라 기기 이름이 없는 결과를 막는 필터도 다시 적용  
  2. 갱신할 때 화면이 깜박이는 상태 제거  
     -  기기 정보가 출력되는 버블의 container를 AnimatedContainer로 변경  
  3. 갱신 시간 조정
     - 직접 스캔하고 멈추는 과정을 반복하여 내용 갱신
     - 스캔 시간이 너무 짧으면 기기를 찾기도 전에 끊어질 수 있으므로 1초 이상으로 지정
     - 내용 유지를 위해 0.5초의 대기 시간 설정
     - 한 번의 실행에서 1분 동안 2.5초 단위로 반복
       
## 그 외
  1. View화면의 Appbar제목 수정 Devices lists -> View
  2. View화면에서도 검색으로 필터링이 가능하도록 검색 버튼 추가
  3. View화면에서 시간이 지나서 검색이 끝나도 아이콘이 변하지 않는 오류 수정
  4. 블루투스 연결 화면 디자인 수정
  5. 기타 UI 수정
     

## 블루투스 꺼졌을 때  

![image](https://github.com/user-attachments/assets/f183a1d0-5395-4677-b5a2-57337e181433)  


## 기본화면  

![image](https://github.com/user-attachments/assets/5c00572d-2163-40ee-9d41-a6fc145ff2af)  


## 기본화면 필터링  

![image](https://github.com/user-attachments/assets/9fc9c8e8-726d-4fd5-8287-0b52297c08cc)  


![image](https://github.com/user-attachments/assets/512ca8af-3015-41b4-8b37-19c0fc48abb8)



## View 모드

![image](https://github.com/user-attachments/assets/97eb1c8d-c9d8-4f2f-be7c-d615e381b00f)  

## View 모드 필터링  

![image](https://github.com/user-attachments/assets/a5feb9b6-d022-4a8f-b25c-3dc9894acca2)  

![image](https://github.com/user-attachments/assets/ade84c90-8cbb-4d78-a5ca-3e7bc69570bb)

