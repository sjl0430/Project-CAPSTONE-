# UI 디자인 구성
## 1. 주제: 안전모의 위치를 쉽게 파악할 수 있는 UI 화면
  ### 1. rssi값을 기반으로 위치를 그림으로 표현
  ### 2. 방향을 구할 수 있다면 구체적 위치를 표시
  ### 3. GPS가 아닌 BLE만으로 구현할 수 있는 방안 모색  
  
## 2. 아이디어
  ### 의견
  1. 야구장 모양의 큰 화면에서 각 기기들의 위치를 홈베이스를 기준으로 표시  
    문제: 대략적 위치를 알지 못함, 특정 범위의 rssi값이 집중되어 있으면 결과가 화면에서 잘릴 수 있음.
  2. 가장 가까운 기기를 n개만 선별하여 rssi값의 내림차순으로 표시  
    문제: 지속적인 동기화가 필요함.  
  3. 배의 레이더처럼 원을 그려 중심을 기준으로 주변 기기를 표시  
    문제: 방향을 알지 못하면 적용할 수 없음.
  4. 삼각형의 밑변에 평행선을 3 ~ 4개 그어서 나오는 각 영역에 가장 가까운 것부터 1개 / 2개/ 3개... 표시  
    문제: 특정 기기들이 같은 rssi값을 가질 경우에 표기에 문제가 발생  

  ### 결론
  1. rssi값을 표기하지 않고 기기명만 표시한 후, 기기명을 클릭하면 세부내용을 볼 수 있게 기능을 추가하여 한 눈에 보기 쉽게 하기
  2. 등록/연결한 기기만 표시하도록 설정하여 혼선을 방지
  3. 레이더의 경우 산업 현장에서 비콘을 따로 설치하여 안전모의 구체적인 위치를 유추할 수 있을 때 적용 가능하므로 추가적인 기능으로 보류
  4. 단순하면서도 화면을 가득 채우는 것이 좋다고 판단, 직사각형에 rssi값 별로 영역을 설정하여 등록된 기기의 모습만 보이도록 표현
  
## 3. 디자인 초안
  ### 1번 시도
  ![1000000715](https://github.com/user-attachments/assets/00c60166-883e-4d6e-ad87-72db752c23d2)

  ### 2번 시도
  ![1000000763](https://github.com/user-attachments/assets/0f08dd9e-e993-4214-9a86-24145da61c92)
