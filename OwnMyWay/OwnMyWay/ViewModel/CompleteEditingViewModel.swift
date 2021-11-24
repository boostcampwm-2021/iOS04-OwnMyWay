//
//  CompleteEditingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Foundation

protocol CompleteEditingViewModel {
    var errorPublisher: Published<Error?>.Publisher { get }

    func didTouchCompleteButton()
}

protocol CompleteEditingCoordinatingDelegate: AnyObject {
    func popToTravelViewController(travel: Travel)
}

class DefaultCompleteEditingViewModel: CompleteEditingViewModel {
    var errorPublisher: Published<Error?>.Publisher { $error }
    private let usecase: CompleteEditingUsecase
    private weak var coordinatingDelegate: CompleteEditingCoordinatingDelegate?
    private let travel: Travel
    @Published private var error: Error?

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
        switch self.usecase.executeUpdate(travel: travel) {
        case .success:
            self.coordinatingDelegate?.popToTravelViewController(travel: travel)
        case .failure(let error):
            self.error = error
        }
    }
}
