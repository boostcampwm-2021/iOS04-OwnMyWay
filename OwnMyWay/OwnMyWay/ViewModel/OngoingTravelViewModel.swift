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
    func didTouchEditButton()
    func didTouchFinishButton() -> Result<Void, Error>
    func didUpdateCoordinate(latitude: Double, longitude: Double)
    func didUpdateRecord(record: Record)
}

protocol StartedCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord(record: Record?)
    func pushToEditTravel(travel: Travel)
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

    func didDeleteTravel() -> Result<Void, Error> {
        switch self.usecase.executeDeletion(of: self.travel) {
        case .success:
            self.coordinatingDelegate?.popToHome()
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
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

    func didTouchEditButton() {
        self.coordinatingDelegate?.pushToEditTravel(travel: self.travel)
    }

    func didTouchFinishButton() -> Result<Void, Error> {
        self.travel.flag = Travel.Section.outdated.index
        switch self.usecase.executeFlagUpdate(of: self.travel) {
        case .success:
            self.coordinatingDelegate?.moveToOutdated(travel: self.travel)
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
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
