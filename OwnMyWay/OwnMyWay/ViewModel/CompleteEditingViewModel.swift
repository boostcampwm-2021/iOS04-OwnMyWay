//
//  CompleteEditingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Foundation

protocol CompleteEditingViewModel {
    func bind(errorHandler: @escaping (Error) -> Void)
    func didTouchCompleteButton()
}

protocol CompleteEditingCoordinatingDelegate: AnyObject {
    func popToTravelViewController(travel: Travel)
}

class DefaultCompleteEditingViewModel: CompleteEditingViewModel {

    private let usecase: CompleteEditingUsecase
    private weak var coordinatingDelegate: CompleteEditingCoordinatingDelegate?
    private let travel: Travel
    private var errorHandler: ((Error) -> Void)?

    init(
        usecase: CompleteEditingUsecase,
        coordinatingDelegate: CompleteEditingCoordinatingDelegate,
        travel: Travel
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.travel = travel
    }

    func bind(errorHandler: @escaping (Error) -> Void) {
        self.errorHandler = errorHandler
    }

    func didTouchCompleteButton() {
        switch self.usecase.executeUpdate(travel: travel) {
        case .success:
            self.coordinatingDelegate?.popToTravelViewController(travel: travel)
        case .failure(let error):
            self.errorHandler?(error)
        }
    }
}
