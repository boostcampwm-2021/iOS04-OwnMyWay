<p align="center">
    <img src="https://i.imgur.com/7UM436I.png" />
</p>

<p align="center">
    <img src="https://img.shields.io/badge/Swift-v5.0-red?logo=swift" />
    <img src="https://img.shields.io/badge/Xcode-v13.0-blue?logo=Xcode" />
    <img src="https://img.shields.io/badge/iOS-13.0+-black?logo=apple" />  
</p>

# ✈️ OwnMyWay

OwnMyWay는 나만의 여행을 계획하고 기록할 수 있는 서비스입니다.

> 여행 중 방문할 장소를 **계획**하고, 여행이 시작되면 방문한 위치를 **기록**하며 글과 사진을 남길 수 있습니다.
> 이동 경로와 남긴 글을 통해 지난 여행도 생생하게 **추억**할 수 있습니다.

### 여행을 계획해보세요.

- 방문할 관광명소를 찜 해보세요. 📌 
- 여행 경로를 남겨보세요. 🧭

### 여행을 추억해보세요.

- 사진과 글로 기록을 남겨보세요. 🌉

---

# ✔︎ 목차

1. [팀 소개](#👨‍👦‍👦-팀-소개)
2. [주요 기능](#💡-주요-기능)
3. [Framework](#📚-Framework)
4. [기술 특장점](#🛠-기술-특장점)
5. [Challenges & TroubleShooting](#Challenges-and-TroubleShooting)
6. [라이센스](#라이센스)
7. [문의](#문의)

---

# 👨‍👨‍👦‍👦 팀 소개

|         [S004 강현준](https://github.com/mandeuk26)          |         [S012 김우재](https://github.com/kimwj9792)          |          [S033 유한준](https://github.com/hj56775)           |         [S047 이청수](https://github.com/bestowing)          |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| <a href="url"><img src="https://avatars.githubusercontent.com/mandeuk26"></a> | <a href="url"><img src="https://avatars.githubusercontent.com/kimwj9792"></a> | <a href="url"><img src="https://avatars.githubusercontent.com/hj56775"></a> | <a href="url"><img src="https://avatars.githubusercontent.com/bestowing" ></a> |

---

# 💡 주요 기능

## 📐 방문할 관광명소와 함께 여행 계획하기

<img src="https://i.imgur.com/dgMm1Vu.png" width="32%" /> <img src="https://i.imgur.com/TGvDtch.jpg" width="32%" /> <img src="https://i.imgur.com/UaU2fht.jpg" width="32%" />

- 여행의 제목과 여행 날짜, 방문할 관광명소를 추가할 수 있습니다.
- 관광 명소는 검색이 가능하며, 지도로 대략적인 위치를 파악할 수 있습니다.

<br />

## 🖊️ 위치정보, 사진과 글로 여행 기록하기

<img src="https://i.imgur.com/sxcqHLe.jpg" width="32%" /> <img src="https://i.imgur.com/MAvgif2.jpg" width="32%" /> <img src="https://i.imgur.com/Rvv1D2j.jpg" width="32%" />

> 여행에서 남는건 기록뿐이죠!

- 기록하고 싶은 일이 생겼나요? 사진과 글을 추가해서 기록할 수 있습니다.
- 각 기록은 친구들에게 공유할 수 있게 폴라로이드 형태로 만들어드립니다.
- 위치정보를 받아 지도에 경로를 그릴 수도 있습니다.
- 이동 경로와 방문한 관광명소, 여행 중간에 남긴 사진과 글을 모두 지도 위에 표시해드려요.

<br />

## 💭 여행을 한눈에 보면서 추억하기

<img src="https://i.imgur.com/P7LjPvV.jpg" width="32%" /> <img src="https://i.imgur.com/U6VRMrW.jpg" width="32%" /> <img src="https://i.imgur.com/6kdaJHP.jpg" width="32%" />

- 기록된 여행은 언제든지 그대로 꺼내 볼 수 있습니다.
- 폴라로이드 사진을 SNS에 공유할 수 있게 **공유하기** 기능을 지원해요.

---

# 📚 Framework
- OwnMyWay에 사용한 Framework는 다음과 같습니다.
- SwiftLint를 제외한 외부 라이브러리를 사용하지 않고 애플 자체 라이브러리만을 사용하였습니다.
![](https://i.imgur.com/JDSz83w.png)

---

# 🛠 기술 특장점
### Accessibility
- OwnMyWay 에서는 접근성을 높이기 위해 다크모드와 보이스오버를 제공합니다.
- [Wiki: Accessibility](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki/Accessibility)에서 자세한 내용을 확인해보세요.
### Clean Architecture & MVVM+C
- OwnMyWay 에서는 코드 재사용성과 교체성을 높이고 원할한 테스트를 진행하기 위해서 MVVM Clean Architecture를 적용하였습니다.
- 또한 화면간의 전환을 담당하는 코디네이터를 추가하여 ViewController를 개선하였습니다.
- [Wiki: Clean Architecture](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki/Clean-Architecture-with-MVVM-C)에서 자세한 내용을 확인해보세요.
### Combine
- OwnMyWay 에서는 하위 Layer부터 상위 Layer로의 이벤트 전달과 비동기 이벤트 처리를 위해 Combine을 사용했습니다.
- [Wiki: Combine](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki/Combine)에서 자세한 내용을 확인해보세요.
### CoreData
- OwnMyWay 에서는 유저가 만든 여행 기록들을 저장하기 위해 CoreData를 사용해 로컬에 저장하는 방식을 사용합니다.
- [Wiki: CoreData](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki/CoreData)에서 자세한 내용을 확인해보세요.
### CoreLocation
- OwnMyWay 에서는 사용자의 경로를 트래킹하기 위해 CoreLocation을 활용하고 있습니다.
- 싱글톤 형태의 CLLocationManager를 사용하여 백그라운드나 다른 화면에 위치해 있어도 트래킹 기능이 동작하도록 만들었습니다.
- [Wiki: CoreLocation](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki/CoreLocation)에서 자세한 내용을 확인해보세요.
### MapKit
- OwnMyWay 에서는 MapKit을 활용해 사용자가 추가한 게시물과 관광명소를 한눈에 확인할 수 있습니다.
- 또한 유저가 이동했던 경로를 선분 형태로 지도에서 확인할 수 있습니다.
- [Wiki: MapKit](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki/MapKit)에서 자세한 내용을 확인해보세요.

---

# 🚀 Challenges and TroubleShooting
- 구현을 하면서 겪은 문제들과 그 해결방안들을 정리해두었습니다.
- [Wiki에서 자세한 내용을 확인해보세요](https://github.com/boostcampwm-2021/iOS04-OwnMyWay/wiki)

---

# 🚗 라이센스

  본 서비스에 사용된 오픈소스의 라이센스는 아래와 같습니다.
  - SwiftLint 0.45.0 (MIT)

---

# 🙋‍♂️ 문의

  문의사항은 issue로 남겨주시기 바랍니다.
