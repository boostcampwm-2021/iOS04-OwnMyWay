//
//  CompleteCreationViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import Foundation

protocol CompleteCreationViewModel {
    func bind(errorHandler: @escaping (Error) -> Void)
    func didTouchCompleteButton()
}

protocol CompleteCreationCoordinatingDelegate: AnyObject {
    func popToHome()
}

class DefaultCompleteCreationViewModel: CompleteCreationViewModel {

    private let usecase: CompleteCreationUsecase
    private weak var coordinatingDelegate: CompleteCreationCoordinatingDelegate?
    private let travel: Travel
    private var errorHandler: ((Error) -> Void)?

    init(
        usecase: CompleteCreationUsecase,
        coordinatingDelegate: CompleteCreationCoordinatingDelegate,
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
        switch self.usecase.executeCreation(travel: travel) {
        case .success:
            self.coordinatingDelegate?.popToHome()
        case .failure(let error):
            self.errorHandler?(error)
        }
    }
}
