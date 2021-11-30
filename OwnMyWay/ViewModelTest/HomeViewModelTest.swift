//
//  HomeViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest
import Combine

class HomeViewModelTest: XCTestCase {

    var viewModel: HomeViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = DefaultHomeViewModel(
            usecase: MockUsecase(),
            coordinatingDelegate: MockDelegate()
        )
        cancellables = []
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
        cancellables = nil
    }
    
    func test_예정된_여행_불러오기() {
        let expectation = XCTestExpectation()
        let expectedValue = ["test1", "test2"]
        var loadedValue: [String] = []
        self.viewModel.reservedTravelPublisher.sink { result in
            loadedValue = result.compactMap { $0.title }
            expectation.fulfill()
        }.store(in: &cancellables)
        viewModel.viewDidLoad()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(expectedValue, loadedValue)
    }

    func test_진행중인_여행_불러오기() {
        let expectation = XCTestExpectation()
        let expectedValue = ["test3", "test4"]
        var loadedValue: [String] = []
        self.viewModel.ongoingTravelPublisher.sink { result in
            loadedValue = result.compactMap { $0.title }
            expectation.fulfill()
        }.store(in: &cancellables)
        viewModel.viewDidLoad()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(expectedValue, loadedValue)
    }

    func test_지난_여행_불러오기() {
        let expectation = XCTestExpectation()
        let expectedValue = ["test5", "test6"]
        var loadedValue: [String] = []
        self.viewModel.outdatedTravelPublisher.sink { result in
            loadedValue = result.compactMap { $0.title }
            expectation.fulfill()
        }.store(in: &cancellables)
        viewModel.viewDidLoad()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(expectedValue, loadedValue)
    }

}

class MockUsecase: HomeUsecase {
    func executeFetch(completion: @escaping (Result<[Travel], Error>) -> Void) {
        completion(.success([
            Travel(uuid: UUID(), flag: 0, title: "test1", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []),
            Travel(uuid: UUID(), flag: 0, title: "test2", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []),
            Travel(uuid: UUID(), flag: 1, title: "test3", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []),
            Travel(uuid: UUID(), flag: 1, title: "test4", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []),
            Travel(uuid: UUID(), flag: 2, title: "test5", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: []),
            Travel(uuid: UUID(), flag: 2, title: "test6", startDate: Date(), endDate: Date(), landmarks: [], records: [], locations: [])
        ]))
    }
}

class MockDelegate: HomeCoordinatingDelegate {
    func pushToCreateTravel() { }
    func pushToReservedTravel(travel: Travel) { }
    func pushToOngoingTravel(travel: Travel) { }
    func pushToOutdatedTravel(travel: Travel) { }
}
