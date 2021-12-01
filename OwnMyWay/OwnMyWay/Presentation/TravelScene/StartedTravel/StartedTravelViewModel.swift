//
//  StartedTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

typealias StartedTravelViewModel = OngoingTravelViewModel & OutdatedTravelViewModel

final class DefaultStartedTravelViewModel: StartedTravelViewModel {

    var travelPublisher: Published<Travel>.Publisher { $travel }
    var errorPublisher: Published<Error?>.Publisher { $error }

    @Published private(set) var travel: Travel
    @Published private var error: Error?

    private let usecase: StartedTravelUsecase
    private weak var coordinatingDelegate: StartedTravelCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: StartedTravelUsecase,
        coordinatingDelegate: StartedTravelCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel
    }

    func didDeleteTravel() {
        self.usecase.executeDeletion(of: self.travel) { [weak self] result in
            switch result {
            case .success:
                self?.coordinatingDelegate?.popToHome()
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func viewWillAppear() {
        self.usecase.executeFetch(of: self.travel) { [weak self] result in
            switch result {
            case .success(let travel):
                self?.travel = travel
            case .failure(let error):
                self?.error = error
            }
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

    func didTouchFinishButton() {
        self.travel.flag = Travel.Section.outdated.index
        self.usecase.executeFlagUpdate(of: self.travel) { [weak self] result in
            switch result {
            case .success(let travel):
                self?.coordinatingDelegate?.moveToOutdated(travel: travel)
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didUpdateCoordinate(latitude: Double, longitude: Double) {
        self.travel.locations.append(Location(latitude: latitude, longitude: longitude))
        self.usecase.executeLocationUpdate(
            of: self.travel, latitude: latitude, longitude: longitude
        ) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didUpdateRecord(record: Record) {
        self.usecase.executeRecordAddition(to: self.travel, with: record) { [weak self] result in
            switch result {
            case .success(let travel):
                self?.travel = travel
            case .failure(let error):
                self?.error = error
            }
        }
    }
}
