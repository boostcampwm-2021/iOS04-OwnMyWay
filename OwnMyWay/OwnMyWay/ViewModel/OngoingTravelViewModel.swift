//
//  OngoingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation

protocol OngoingTravelViewModel {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }

    func didUpdateTravel(to travel: Travel)
    func didTouchAddRecordButton()
    func didTouchRecordCell(at record: Record)
    func didTouchBackButton()
    func didTouchEditTravelButton()
    func didTouchFinishButton()
}

protocol OngoingCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord(travel: Travel)
    func pushToEditTravel()
    func moveToOutdated(travel: Travel)
    func pushToDetailRecord(record: Record)
}

class DefaultOngoingTravelViewModel: OngoingTravelViewModel {
    var travelPublisher: Published<Travel>.Publisher { $travel }

    @Published private(set) var travel: Travel

    private let usecase: OngoingTravelUsecase
    private weak var coordinatingDelegate: OngoingCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: OngoingTravelUsecase,
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

    func didTouchRecordCell(at record: Record) {
        self.coordinatingDelegate?.pushToDetailRecord(record: record)
    }

    func didTouchBackButton() {}
    func didTouchEditTravelButton() {}

    func didTouchFinishButton() {
        self.travel.flag = Travel.Section.outdated.index
        self.usecase.executeFlagUpdate(of: self.travel)
        self.coordinatingDelegate?.moveToOutdated(travel: self.travel)
    }
}
