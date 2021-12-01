//
//  ReservedTravelViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest
import Combine

class ReservedTravelViewModelTest: XCTestCase {

    var viewModel: ReservedTravelViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        cancellables = nil
    }
    
    func test_시작불가능한_여행일때() {
        viewModel = DefaultReservedTravelViewModel(
            usecase: ReservedTravelUsecaseMock(),
            travel:
                Travel(uuid: UUID(), flag: 0, title: "invalid travel", startDate: Date().addingTimeInterval(86400), endDate: Date().addingTimeInterval(86400), landmarks: [], records: [], locations: []),
            coordinatingDelegate: ReservedTravelDelegateMock()
        )
        XCTAssertEqual(self.viewModel.isPossibleStart, false)
    }
    
    func test_여행_수정되었을때() {
        var travel = Travel(uuid: UUID(), flag: 0, title: "before", startDate: Date(), endDate: Date().addingTimeInterval(86400), landmarks: [], records: [], locations: [])
        viewModel = DefaultReservedTravelViewModel(
            usecase: ReservedTravelUsecaseMock(),
            travel: travel,
            coordinatingDelegate: ReservedTravelDelegateMock()
        )
        travel.title = "after"
        self.viewModel.didUpdateTravel(to: travel)
        XCTAssertEqual(self.viewModel.travel.title, "after")
    }
    
    func test_관광명소_삭제했을때() {
        let landmark = Landmark(uuid: UUID(), image: .init(string: "test"), latitude: 0.0, longitude: 0.0, title: "title")
        viewModel = DefaultReservedTravelViewModel(
            usecase: ReservedTravelUsecaseMock(),
            travel:
                Travel(uuid: UUID(), flag: 0, title: "invalid travel", startDate: Date(), endDate: Date().addingTimeInterval(86400), landmarks: [landmark], records: [], locations: []),
            coordinatingDelegate: ReservedTravelDelegateMock()
        )
        self.viewModel.didDeleteLandmark(at: landmark)
        XCTAssertEqual(self.viewModel.travel.landmarks.count, 0)
    }
}

class ReservedTravelUsecaseMock: ReservedTravelUsecase {
    func executeDeletion(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {}
    func executeLandmarkAddition(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {}
    func executeLandmarkDeletion(at landmark: Landmark, completion: @escaping (Result<Void, Error>) -> Void) {}
    func executeFlagUpdate(of travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void) {}
}

class ReservedTravelDelegateMock: ReservedTravelCoordinatingDelegate {
    func popToHome() {}
    func moveToOngoing(travel: Travel) {}
    func pushToEditTravel(travel: Travel) {}
}
