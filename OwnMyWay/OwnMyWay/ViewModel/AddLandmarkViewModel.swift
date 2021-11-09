//
//  AddLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import Foundation

protocol AddLandmarkViewModel {
    var travel: Travel { get }
    func didTouchNextButton()
    func didTouchBackButton()
    func didUpdateTravel(to travel: Travel)
}

protocol AddLandmarkCoordinatingDelegate: AnyObject {
    func pushToCompleteCreation(travel: Travel)
    func popToCreateTravel(travel: Travel)
}

class DefaultAddLandmarkViewModel: AddLandmarkViewModel {

    private(set) var travel: Travel
    private weak var coordinatingDelegate: AddLandmarkCoordinatingDelegate?

    init(travel: Travel, coordinatingDelegate: AddLandmarkCoordinatingDelegate) {
        self.travel = travel
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didTouchNextButton() {
        self.coordinator?.pushToCompleteCreation(travel: travel)
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToCreateTravel(travel: travel)
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel
    }
}
