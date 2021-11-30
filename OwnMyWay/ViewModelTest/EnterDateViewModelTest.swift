//
//  EnterDateViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import Combine
import XCTest

class EnterDateViewModelTest: XCTestCase {

    var viewModel: DefaultEnterDateViewModel!
    var coordinator: MockCoordinator!

    class MockCoordinator: EnterDateCoordinatingDelegate {
        var travel: Travel?

        func pushToEnterDate(travel: Travel, isEditingMode: Bool) {
            self.travel = travel
            return
        }

        func pushToAddLandmark(travel: Travel, isEditingMode: Bool) {}
        
        func popToCreateTravel(travel: Travel) {}
    }

    override func setUp() {
        super.setUp()
        self.coordinator = MockCoordinator()
        self.viewModel = DefaultEnterDateViewModel(
            usecase: DefaultEnterDateUsecase(),
            coordinatingDelegate: self.coordinator,
            travel: Travel.dummy(section: .dummy),
            isEditingMode: false
        )
    }

    override func tearDown() {
        self.coordinator = nil
        self.viewModel = nil
        super.tearDown()
    }

}

// 청수
