//
//  OngoingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation

protocol OngoingViewModel {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }

    func didUpdateTravel(to travel: Travel)
    func didTouchAddRecordButton()
    func didTouchBackButton()
    func didTouchEditTravelButton()
    func didTouchFinishButton()
}

protocol OngoingCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord(travel: Travel)
    func pushToEditTravel()
    func moveToOutdated(travel: Travel)
}

class DefaultOngoingViewModel: OngoingViewModel {
    var travelPublisher: Published<Travel>.Publisher { $travel }

    @Published private(set) var travel: Travel

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

    func didTouchAddRecordButton() {
        self.coordinatingDelegate?.pushToAddRecord(travel: self.travel)
    }

    func didTouchBackButton() {}
    func didTouchEditTravelButton() {}

    func didTouchFinishButton() {
        self.travel.flag = Travel.Section.outdated.index
        self.usecase.executeFlagUpdate(of: self.travel)
        self.coordinatingDelegate?.moveToOutdated(travel: self.travel)
    }
}
