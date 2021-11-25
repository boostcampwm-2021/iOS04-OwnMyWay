//
//  ReservedTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

protocol ReservedTravelViewModel {
    var travel: Travel { get }
    var isPossibleStart: Bool { get }
    var travelPublisher: Published<Travel>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }

    func didDeleteTravel()
    func didUpdateTravel(to travel: Travel)
    func didEditTravel(to travel: Travel)
    func didDeleteLandmark(at landmark: Landmark)
    func didTouchBackButton()
    func didTouchStartButton()
    func didTouchEditButton()
}

protocol ReservedTravelCoordinatingDelegate: AnyObject {
    func popToHome()
    func moveToOngoing(travel: Travel)
    func pushToEditTravel(travel: Travel)
}

final class DefaultReservedTravelViewModel: ReservedTravelViewModel, ObservableObject {
    @Published private(set) var travel: Travel
    @Published private var error: Error?
    private(set) var isPossibleStart: Bool
    var travelPublisher: Published<Travel>.Publisher { $travel }
    var errorPublisher: Published<Error?>.Publisher { $error }

    private let usecase: ReservedTravelUsecase
    private weak var coordinatingDelegate: ReservedTravelCoordinatingDelegate?

    init(
        usecase: ReservedTravelUsecase,
        travel: Travel,
        coordinatingDelegate: ReservedTravelCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        if let startDate = travel.startDate {
            self.isPossibleStart = startDate <= Date()
        } else {
            self.isPossibleStart = false
        }
        self.coordinatingDelegate = coordinatingDelegate
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

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel // 자기자신에 업데이트
        self.usecase.executeLandmarkAddition(of: travel) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didEditTravel(to travel: Travel) {
        self.travel = travel
    }

    func didDeleteLandmark(at landmark: Landmark) {
        guard let index = self.travel.landmarks.firstIndex(of: landmark) else {
            self.error = ModelError.landmarkError
            return
        }
        self.travel.landmarks.remove(at: index)

        self.usecase.executeLandmarkDeletion(at: landmark) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToHome()
    }

    func didTouchStartButton() {
        self.travel.flag = Travel.Section.ongoing.index // 자기자신에 업데이트
        self.usecase.executeFlagUpdate(of: self.travel) { [weak self] result in
            switch result {
            case .success(let travel):
                self?.coordinatingDelegate?.moveToOngoing(travel: travel)
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didTouchEditButton() {
        self.coordinatingDelegate?.pushToEditTravel(travel: self.travel)
    }

}
