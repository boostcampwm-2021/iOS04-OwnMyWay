//
//  EnterTitleViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import Combine
import XCTest

class EnterTitleViewModelTest: XCTestCase {

    var viewModel: EnterTitleViewModel!
    var coordinator: MockCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    class MockCoordinator: EnterTitleCoordinatingDelegate {
        var travel: Travel?
        
        func pushToEnterDate(travel: Travel, isEditingMode: Bool) {
            self.travel = travel
            return
        }
    }
    
    override func setUp() {
        coordinator = MockCoordinator()
        viewModel = DefaultEnterTitleViewModel(
            usecase: DefaultEnterTitleUsecase(),
            coordinatingDelegate: self.coordinator,
            travel: nil
        )
        cancellables = []
    }

    override func tearDown() {
        coordinator = nil
        viewModel = nil
        cancellables = nil
    }
    
    func test_텍스트_입력() {
        let expectation = XCTestExpectation()

        self.viewModel.validatePublisher
            .sink { result in
                if result == nil { return }
                
                if result == true {
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.didChangeTitle(text: "테스트입니다.")
        wait(for: [expectation], timeout: 1)
    }
    
    func test_텍스트_입력_실패() {
        let expectation = XCTestExpectation()

        self.viewModel.validatePublisher
            .sink { result in
                if result == nil { return }
                
                if result == true {
                    XCTFail()
                } else {
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.didChangeTitle(text: "")
        wait(for: [expectation], timeout: 1)
    }

    func test_다음_버튼_클릭() {
        self.viewModel.didChangeTitle(text: "테스트입니다.")
        self.viewModel.didTouchNextButton()
        XCTAssertNotNil(self.coordinator.travel)
        XCTAssertTrue(self.coordinator.travel?.title == "테스트입니다.")
    }

}
