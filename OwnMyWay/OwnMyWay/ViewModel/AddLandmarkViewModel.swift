//
//  AddLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import Foundation

protocol AddLandmarkViewModelType {
    func nextButtonTouched()
}

protocol AddLandmarkCoordinatingDelegate: AnyObject {
    func pushToComplete(travel: Travel)
}

class AddLandmarkViewModel: AddLandmarkViewModelType {

    private weak var coordinator: AddLandmarkCoordinatingDelegate?
    private var travel: Travel

    init(travel: Travel, coordinator: AddLandmarkCoordinatingDelegate) {
        self.travel = travel
        self.coordinator = coordinator
    }

    func nextButtonTouched() {
        self.coordinator?.pushToComplete(travel: travel)
    }
}
