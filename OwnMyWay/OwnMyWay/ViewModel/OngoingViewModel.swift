//
//  OngoingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation

protocol OngoingViewModel {
    var travelPublisher: Published<Travel>.Publisher { get }

    func didUpdateTravel(to travel: Travel)
    func didTouchAddRecordButton()
    func didTouchBackButton()
    func didTouchEditTravelButton()
    func didTouchFinishButton()
}

protocol OngoingCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord()
    func pushToEditTravel()
}

class DefaultOngoingViewModel: OngoingViewModel {
    var travelPublisher: Published<Travel>.Publisher { $travel }

    @Published private var travel: Travel

    private let usecase: OngoingUsecase
    private weak var coordinatingDelegate: OngoingCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: OngoingUsecase,
        coordinatingDelegate: OngoingCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didUpdateTravel(to travel: Travel) {}
    func didTouchAddRecordButton() {}
    func didTouchBackButton() {}
    func didTouchEditTravelButton() {}
    func didTouchFinishButton() {}
}
