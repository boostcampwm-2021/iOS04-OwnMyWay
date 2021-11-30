//
//  EnterDateViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import Combine
import XCTest

class EnterDateViewModelTest: XCTestCase {

    private var viewModel: DefaultEnterDateViewModel!
    private var coordinator: MockCoordinator!
    private var cancellable: AnyCancellable!
    private let timeout: TimeInterval = 3

    class MockCoordinator: EnterDateCoordinatingDelegate {
        var travel: Travel?

        func pushToEnterDate(travel: Travel, isEditingMode: Bool) {}

        func pushToAddLandmark(travel: Travel, isEditingMode: Bool) {}

        func popToCreateTravel(travel: Travel) {}
    }

    class MockUsecase: EnterDateUsecase {

        func executeEnteringDate(
            firstDate: Date, secondDate: Date, completion: ([Date]) -> Void
        ) {
            completion([])
        }

    }

    override func setUp() {
        super.setUp()
        let emtpyTravel = Travel(
            uuid: nil, flag: 0, title: nil, startDate: nil,
            endDate: nil, landmarks: [], records: [], locations: []
        )
        self.coordinator = MockCoordinator()
        self.viewModel = DefaultEnterDateViewModel(
            usecase: MockUsecase(),
            coordinatingDelegate: self.coordinator,
            travel: emtpyTravel,
            isEditingMode: false
        )
    }

    override func tearDown() {
        self.coordinator = nil
        self.viewModel = nil
        super.tearDown()
    }

    func test_초기_뷰_로드() {
        // Given
        let expectation = XCTestExpectation()
        let expect: (Date?, Date?) = (nil, nil)
        var actual: (Date?, Date?)

        // When
        self.viewModel.viewDidLoad { firstDate, secondDate in
            actual = (firstDate, secondDate)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expect.0 == actual.0 && expect.1 == actual.1)
    }

    func test_날짜입력_한번만_입력한_경우() {
        // Given
        let expectation = XCTestExpectation()
        let expectedStatus: [CalendarState] = [.empty, .firstDateEntered]
        var actualStatus: [CalendarState] = []
        self.cancellable = self.viewModel
            .calendarStatePublisher
            .sink { status in
            actualStatus.append(status)
            if actualStatus.count == 2 {
                expectation.fulfill()
            }
        }

        // When
        self.viewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }
    
    func test_날짜입력_2번_입력한_경우() {
        // Given
        let expectation = XCTestExpectation()
        let expectedStatus: [CalendarState] = [.empty, .firstDateEntered, .fulfilled]
        var actualStatus: [CalendarState] = []
        self.cancellable = self.viewModel
            .calendarStatePublisher
            .sink { status in
            actualStatus.append(status)
            if actualStatus.count == 3 {
                expectation.fulfill()
            }
        }

        // When
        self.viewModel.didEnterDate(at: Date())
        self.viewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }

    func test_날짜입력_3번_입력한_경우() {
        // Given
        let expectation = XCTestExpectation()
        let expectedStatus: [CalendarState] = [.empty, .firstDateEntered, .fulfilled, .empty]
        var actualStatus: [CalendarState] = []
        self.cancellable = self.viewModel
            .calendarStatePublisher
            .sink { status in
            actualStatus.append(status)
                if actualStatus.count == 4 {
                expectation.fulfill()
            }
        }

        // When
        self.viewModel.didEnterDate(at: Date())
        self.viewModel.didEnterDate(at: Date())
        self.viewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }

    func test_아니오_버튼_터치한_경우() {
        // When
        self.viewModel.didTouchBackButton()

        // Then
        XCTAssertNil(self.viewModel.travel.startDate)
        XCTAssertNil(self.viewModel.travel.endDate)
    }

}
