//
//  LandmarkCartViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import Combine
import XCTest

class LandmarkCartCoordinatorMock: LandmarkCartCoordinatingDelegate {
    func presentSearchLandmarkModally() { return }
}

class LandmarkCartViewModelTest: XCTestCase {

    var viewModel: LandmarkCartViewModel!
    var coordinator: LandmarkCartCoordinatingDelegate!
    var cancellables: [AnyCancellable]!
    
    override func setUp() {
        super.setUp()
        self.coordinator = LandmarkCartCoordinatorMock()
        self.viewModel = DefaultLandmarkCartViewModel(
            coordinatingDelegate: self.coordinator, travel: Travel.dummy(section: .dummy), superVC: .create
        )
        self.cancellables = []
    }

    override func tearDown() {
        self.coordinator = nil
        self.viewModel = nil
        self.cancellables = nil
        super.tearDown()
    }
    
    func test_관광명소_삽입_성공() {
        let expectation = XCTestExpectation()
        var resultTravel: Travel?
        
        self.viewModel.travelPublisher
            .sink{ result in
                resultTravel = result
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        let landmark = Landmark(uuid: UUID(), image: URL(string: ""), latitude: 75, longitude: 75, title: "테스트 관광 명소")
        
        self.viewModel.didAddLandmark(with: landmark)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(resultTravel)
        XCTAssertEqual(resultTravel!.landmarks.last, landmark, "관광명소가 제대로 삽입되지 않았습니다")
    }
    
    func test_관광명소_삭제_성공() {
        let expectation = XCTestExpectation()
        var resultTravel: Travel?
        
        self.viewModel.travelPublisher
            .sink{ result in
                resultTravel = result
                expectation.fulfill()
            }
            .store(in: &cancellables)

        let landmark = Landmark(uuid: UUID(), image: URL(string: ""), latitude: 75, longitude: 75, title: "테스트 관광 명소")

        self.viewModel.didAddLandmark(with: landmark)
        
        let deletedLandmark = self.viewModel.didDeleteLandmark(at: 0)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(deletedLandmark, landmark, "제대로 된 관광명소가 지워지지 않습니다.")
        XCTAssertEqual(resultTravel!.landmarks, [], "관광명소가 제대로 지워지지 않았습니다.")
    }
    
    func test_관광명소_검색_성공() {
        let landmark = Landmark(uuid: UUID(), image: URL(string: ""), latitude: 75, longitude: 75, title: "테스트 관광 명소")
        
        self.viewModel.didAddLandmark(with: landmark)
        let foundLandmark = self.viewModel.findLandmark(at: 0)
        
        XCTAssertEqual(landmark, foundLandmark, "관광명소를 제대로 찾지 못했습니다.")
    }
    
    func test_여행_업데이트_성공() {
        let expectation = XCTestExpectation()
        let travel = Travel(
            uuid: UUID(), flag: 0, title: "테스트 여행", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []
        )
        var resultTravel: Travel?
        
        self.viewModel.travelPublisher
            .sink{ result in
                resultTravel = result
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        self.viewModel.didUpdateTravel(to: travel)
        
        XCTAssertEqual(resultTravel, travel, "여행이 업데이트되지 않았습니다.")
    }
}

// 한준
