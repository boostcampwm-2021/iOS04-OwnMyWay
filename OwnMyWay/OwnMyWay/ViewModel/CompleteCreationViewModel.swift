//
//  CompleteCreationViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import Foundation

protocol CompleteCreationViewModel {
    var errorPublisher: Published<Error?>.Publisher { get }

    func didTouchCompleteButton()
}

protocol CompleteCreationCoordinatingDelegate: AnyObject {
    func popToHome()
}

class DefaultCompleteCreationViewModel: CompleteCreationViewModel {
    var errorPublisher: Published<Error?>.Publisher { $error }
    private let usecase: CompleteCreationUsecase
    private weak var coordinatingDelegate: CompleteCreationCoordinatingDelegate?
    private let travel: Travel
    @Published private var error: Error?

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
        switch self.usecase.executeCreation(travel: travel) {
        case .success:
            self.coordinatingDelegate?.popToHome()
        case .failure(let error):
            self.error = error
        }
    }
}
