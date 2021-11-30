//
//  EnterDateViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import Combine
import XCTest

class EnterDateViewModelTest: XCTestCase {

    private var creatingViewModel: EnterDateViewModel!
    private var editingViewModel: EnterDateViewModel!
    private var coordinator: MockCoordinator!
    private var cancellable: AnyCancellable!
    private let timeout: TimeInterval = 3
    private let startDate = Date(timeIntervalSince1970: 0)
    private let endDate = Date(timeIntervalSince1970: 100)

    class MockCoordinator: EnterDateCoordinatingDelegate {
        var travel: Travel?

        func pushToEnterDate(travel: Travel, isEditingMode: Bool) {}

        func pushToAddLandmark(travel: Travel, isEditingMode: Bool) {}

        func popToCreateTravel(travel: Travel) {}
    }

    class MockUsecase: EnterDateUsecase {
        func executeEnteringDate(
            firstDate: Date, secondDate: Date, completion: ([Date]) -> Void
        ) {}
    }

    override func setUp() {
        super.setUp()
        self.coordinator = MockCoordinator()

        let emtpyTravel = Travel(
            uuid: nil, flag: 0, title: nil, startDate: nil,
            endDate: nil, landmarks: [], records: [], locations: []
        )
        self.creatingViewModel = DefaultEnterDateViewModel(
            usecase: MockUsecase(),
            coordinatingDelegate: self.coordinator,
            travel: emtpyTravel,
            isEditingMode: false
        )

        let travel = Travel(
            uuid: nil, flag: 0, title: nil, startDate: startDate,
            endDate: endDate, landmarks: [], records: [], locations: [])
        self.editingViewModel = DefaultEnterDateViewModel(
            usecase: MockUsecase(),
            coordinatingDelegate: self.coordinator,
            travel: travel,
            isEditingMode: false
        )
    }

    override func tearDown() {
        self.coordinator = nil
        self.creatingViewModel = nil
        super.tearDown()
    }

    func test_초기_뷰_로드() {
        // Given
        let expectation = XCTestExpectation()
        let expect: (Date?, Date?) = (nil, nil)
        var actual: (Date?, Date?)

        // When
        self.creatingViewModel.viewDidLoad { firstDate, secondDate in
            actual = (firstDate, secondDate)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expect.0 == actual.0 && expect.1 == actual.1)
    }

    func test_초기_뷰_로드_수정할때() {
        // Given
        let expectation = XCTestExpectation()
        let expect: (Date?, Date?) = (self.startDate, self.endDate)
        var actual: (Date?, Date?)

        // When
        self.editingViewModel.viewDidLoad { firstDate, secondDate in
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
        self.cancellable = self.creatingViewModel
            .calendarStatePublisher
            .sink { status in
            actualStatus.append(status)
            if actualStatus.count == 2 {
                expectation.fulfill()
            }
        }

        // When
        self.creatingViewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }
    
    func test_날짜입력_2번_입력한_경우() {
        // Given
        let expectation = XCTestExpectation()
        let expectedStatus: [CalendarState] = [.empty, .firstDateEntered, .fulfilled]
        var actualStatus: [CalendarState] = []
        self.cancellable = self.creatingViewModel
            .calendarStatePublisher
            .sink { status in
            actualStatus.append(status)
            if actualStatus.count == 3 {
                expectation.fulfill()
            }
        }

        // When
        self.creatingViewModel.didEnterDate(at: Date())
        self.creatingViewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }

    func test_날짜입력_3번_입력한_경우() {
        // Given
        let expectation = XCTestExpectation()
        let expectedStatus: [CalendarState] = [.empty, .firstDateEntered, .fulfilled, .empty]
        var actualStatus: [CalendarState] = []
        self.cancellable = self.creatingViewModel
            .calendarStatePublisher
            .sink { status in
            actualStatus.append(status)
                if actualStatus.count == 4 {
                expectation.fulfill()
            }
        }

        // When
        self.creatingViewModel.didEnterDate(at: Date())
        self.creatingViewModel.didEnterDate(at: Date())
        self.creatingViewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }

    func test_날짜입력_수정하는_경우() {
        // Given
        let expectation = XCTestExpectation()
        let expectedStatus: [CalendarState] = [.datesExisted, .empty]
        var actualStatus: [CalendarState] = []
        self.cancellable = self.editingViewModel
            .calendarStatePublisher
            .sink { status in
                print(actualStatus)
            actualStatus.append(status)
                if actualStatus.count == 2 {
                expectation.fulfill()
            }
        }

        // When
        self.editingViewModel.didEnterDate(at: Date())
        wait(for: [expectation], timeout: self.timeout)

        // Then
        XCTAssert(expectedStatus == actualStatus)
    }

    func test_아니오_버튼_터치한_경우() {
        // When
        self.creatingViewModel.didTouchBackButton()

        // Then
        XCTAssertNil(self.creatingViewModel.travel.startDate)
        XCTAssertNil(self.creatingViewModel.travel.endDate)
    }

}
