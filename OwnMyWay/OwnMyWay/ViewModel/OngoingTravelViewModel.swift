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
    func didUpdateCoordinate(latitude: Double, longitude: Double)
    func didUpdateRecord(record: Record)
}

protocol StartedCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord(record: Record?)
    func pushToEditTravel()
    func moveToOutdated(travel: Travel)
    func pushToDetailRecord(record: Record, travel: Travel)
}

class DefaultStartedTravelViewModel: OngoingTravelViewModel, OutdatedTravelViewModel {
    var travelPublisher: Published<Travel>.Publisher { $travel }

    @Published private(set) var travel: Travel

    private let usecase: StartedTravelUsecase
    private weak var coordinatingDelegate: StartedCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: StartedTravelUsecase,
        coordinatingDelegate: StartedCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel
    }

    func didTouchAddRecordButton() {
        self.coordinatingDelegate?.pushToAddRecord(record: nil)
    }

    func didTouchRecordCell(at record: Record) {
        self.coordinatingDelegate?.pushToDetailRecord(record: record, travel: self.travel)
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToHome()
    }

    func didTouchEditTravelButton() {}

    func didTouchFinishButton() {
        self.travel.flag = Travel.Section.outdated.index
        self.usecase.executeFlagUpdate(of: self.travel)
        self.coordinatingDelegate?.moveToOutdated(travel: self.travel)
    }

    func didUpdateCoordinate(latitude: Double, longitude: Double) {
        self.travel.locations.append(Location(latitude: latitude, longitude: longitude))
        self.usecase.executeLocationUpdate(
            of: self.travel, latitude: latitude, longitude: longitude
        )
    }

    func didUpdateRecord(record: Record) {
        self.usecase.executeRecordAddition(to: self.travel, with: record) { [weak self] travel in
            self?.travel = travel
        }
    }
}
