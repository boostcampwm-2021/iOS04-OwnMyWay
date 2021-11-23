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

    func didDeleteTravel() -> Result<Void, Error>
    func didUpdateTravel(to travel: Travel)
    func didEditTravel(to travel: Travel)
    func didDeleteLandmark(at landmark: Landmark) -> Result<Void, Error>
    func didTouchBackButton()
    func didTouchStartButton() -> Result<Void, Error>
    func didTouchEditButton()
}

protocol ReservedTravelCoordinatingDelegate: AnyObject {
    func popToHome()
    func moveToOngoing(travel: Travel)
    func pushToEditTravel(travel: Travel)
}

class DefaultReservedTravelViewModel: ReservedTravelViewModel, ObservableObject {
    @Published private(set) var travel: Travel
    private(set) var isPossibleStart: Bool
    var travelPublisher: Published<Travel>.Publisher { $travel }

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

    func didDeleteTravel() -> Result<Void, Error> {
        switch self.usecase.executeDeletion(of: self.travel) {
        case .success:
            self.coordinatingDelegate?.popToHome()
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel // 자기자신에 업데이트
        self.usecase.executeLandmarkAddition(of: travel) // coreData에 업데이트
    }

    func didEditTravel(to travel: Travel) {
        self.travel = travel
    }

    func didDeleteLandmark(at landmark: Landmark) -> Result<Void, Error> {
        guard let index = self.travel.landmarks.firstIndex(of: landmark)
        else { return .failure(ModelError.landmarkError) }
        self.travel.landmarks.remove(at: index)
        return self.usecase.executeLandmarkDeletion(at: landmark)
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToHome()
    }

    func didTouchStartButton() -> Result<Void, Error> {
        self.travel.flag = Travel.Section.ongoing.index // 자기자신에 업데이트
        switch self.usecase.executeFlagUpdate(of: self.travel) {
        case .success:
            self.coordinatingDelegate?.moveToOngoing(travel: self.travel)
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    func didTouchEditButton() {
        self.coordinatingDelegate?.pushToEditTravel(travel: self.travel)
    }

}
