//
//  AddLandmarkViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import Combine
import XCTest

class AddLandmarkCoordinatorMock: AddLandmarkCoordinatingDelegate {
    func pushToCompleteCreation(travel: Travel) { return }
    func pushToCompleteEditing(travel: Travel) { return }
    func popToEnterDate(travel: Travel) { return }
}

class AddLandmarkViewModelTest: XCTestCase {
    
    var viewModel: AddLandmarkViewModel!
    var coordinator: AddLandmarkCoordinatingDelegate!

    override func setUp() {
        super.setUp()
        self.coordinator = AddLandmarkCoordinatorMock()
        self.viewModel = DefaultAddLandmarkViewModel(travel: Travel.dummy(section: .dummy), coordinatingDelegate: self.coordinator, isEditingMode: true)

    }

    override func tearDown() {
        self.viewModel = nil
        self.coordinator = nil
        super.tearDown()
    }
    
    func test_여행_업데이트_성공() {
        let testTravel = Travel(
            uuid: UUID(), flag: 0, title: "테스트", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []
        )
        
        self.viewModel.didUpdateTravel(to: testTravel)
        
        XCTAssertEqual(self.viewModel.travel, testTravel, "여행이 일치하지 않습니다.")
    }
    
    func test_관광명소_삭제_성공() {
        let testLandmark = Landmark(uuid: UUID(), image: URL(string: ""), latitude: 120, longitude: 120, title: "테스트 장소")
        let testTravel = Travel(uuid: UUID(), flag: 0, title: "테스트 여행", startDate: Date(), endDate: Date(), landmarks: [testLandmark], records: [], locations: [])
        
        self.viewModel.didUpdateTravel(to: testTravel)
        
        self.viewModel.didDeleteLandmark(at: testLandmark)
        
        XCTAssertEqual(self.viewModel.travel.landmarks, [] , "관광명소가 삭제되지 않았습니다.")
    }
    
    func test_관광명소_삭제_실패() {
        let insertLandmark = Landmark(uuid: UUID(), image: URL(string: ""), latitude: 120, longitude: 120, title: "삽입할 장소")
        let deleteLandmark = Landmark(uuid: UUID(), image: URL(string: ""), latitude: 30, longitude: 30, title: "제거할 장소")
        let testTravel = Travel(uuid: UUID(), flag: 0, title: "테스트 여행", startDate: Date(), endDate: Date(), landmarks: [insertLandmark], records: [], locations: [])
        
        self.viewModel.didUpdateTravel(to: testTravel)
        
        self.viewModel.didDeleteLandmark(at: deleteLandmark)
        
        XCTAssertNotEqual(self.viewModel.travel.landmarks, [], "관광명소가 삭제되면 안되는데 삭제되었습니다.ㅌ")
    }
}
