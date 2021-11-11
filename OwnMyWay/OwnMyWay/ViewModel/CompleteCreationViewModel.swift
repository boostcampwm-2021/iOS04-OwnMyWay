//
//  CompleteCreationViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import Foundation

protocol CompleteCreationViewModel {
    func didTouchCompleteButton()
}

protocol CompleteCreationCoordinatingDelegate: AnyObject {
    func popToHome()
}

class DefaultCompleteCreationViewModel: CompleteCreationViewModel {

    private let usecase: CompleteCreationUsecase
    private weak var coordinatingDelegate: CompleteCreationCoordinatingDelegate?
    private let travel: Travel

    init(
        usecase: CompleteCreationUsecase,
        coordinatingDelegate: CompleteCreationCoordinatingDelegate,
        travel: Travel
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.travel = travel
    }

    func didTouchCompleteButton() {
        self.usecase.executeCreation(travel: travel)
        self.coordinatingDelegate?.popToHome()
    }

}
