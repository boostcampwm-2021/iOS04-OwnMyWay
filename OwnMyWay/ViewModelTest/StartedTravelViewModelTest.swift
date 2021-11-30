//
//  StartedTravelViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest
import Combine

class StartedTravelViewModelTest: XCTestCase {

    var viewModel: StartedTravelViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = DefaultStartedTravelViewModel(
            travel: Travel.dummy(section: .dummy),
            usecase: StartedTravelUsecaseMock(),
            coordinatingDelegate: StartedTravelDelegateMock())
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        cancellables = nil
    }
    
    func test_여행_수정했을때() {
        let newTravel = Travel(uuid: UUID(), flag: 1, title: "newTravel", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: [])
        self.viewModel.didUpdateTravel(to: newTravel)
        XCTAssertEqual(self.viewModel.travel.title, "newTravel")
    }
    
    func test_좌표_추가했을때() {
        let beforeLocationCount = self.viewModel.travel.locations.count
        self.viewModel.didUpdateCoordinate(latitude: 0.0, longitude: 0.0)
        let afterLocationCount = self.viewModel.travel.locations.count
        XCTAssertEqual(beforeLocationCount + 1, afterLocationCount)
    }
}

class StartedTravelUsecaseMock: StartedTravelUsecase {
    func executeFetch() {}
    func executeFinishingTravel() {}
    func executeLocationUpdate(of travel: Travel, latitude: Double, longitude: Double, completion: @escaping (Result<Location, Error>) -> Void) {}
    func executeRecordAddition(to travel: Travel, with record: Record, completion: @escaping (Result<Travel, Error>) -> Void) {}
    func executeFlagUpdate(of travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void) {}
    func executeDeletion(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {}
}

class StartedTravelDelegateMock: StartedTravelCoordinatingDelegate {
    func popToHome() {}
    func pushToEditTravel(travel: Travel) {}
    func pushToAddRecord(record: Record?) {}
    func moveToOutdated(travel: Travel) {}
    func pushToDetailRecord(record: Record, travel: Travel) {}
}
