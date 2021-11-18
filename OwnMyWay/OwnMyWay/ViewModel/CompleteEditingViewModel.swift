//
//  CompleteEditingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Foundation

protocol CompleteEditingViewModel {
    func didTouchCompleteButton()
}

protocol CompleteEditingCoordinatingDelegate: AnyObject {
    func popToTravelViewController(travel: Travel)
}

class DefaultCompleteEditingViewModel: CompleteEditingViewModel {

    private let usecase: CompleteEditingUsecase
    private weak var coordinatingDelegate: CompleteEditingCoordinatingDelegate?
    private let travel: Travel

    init(
        usecase: CompleteEditingUsecase,
        coordinatingDelegate: CompleteEditingCoordinatingDelegate,
        travel: Travel
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.travel = travel
    }

    func didTouchCompleteButton() {
        self.usecase.executeUpdate(travel: travel)
        self.coordinatingDelegate?.popToTravelViewController(travel: travel)
    }

}
