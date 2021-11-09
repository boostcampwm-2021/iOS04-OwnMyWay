//
//  ReservedTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

protocol ReservedTravelViewModelType {
    var travel: Travel { get }
    var isPossibleStart: Bool { get }
    func didDeleteTravel()
    func travelDidUpdate(travel: Travel)
}

protocol ReservedTravelCoordinatingDelegate: AnyObject {
    func popToHome()
}

class ReservedTravelViewModel: ReservedTravelViewModelType, ObservableObject {
    var travel: Travel
    var isPossibleStart: Bool

    private let reservedTravelUsecase: ReservedTravelUsecase
    private weak var coordinator: ReservedTravelCoordinatingDelegate?

    init(
        reservedTravelUsecase: ReservedTravelUsecase,
        travel: Travel,
        coordinator: ReservedTravelCoordinatingDelegate
    ) {
        self.travel = travel
        self.reservedTravelUsecase = reservedTravelUsecase
        if let startDate = travel.startDate {
            self.isPossibleStart = startDate <= Date()
        } else {
            self.isPossibleStart = false
        }
        self.coordinator = coordinator
    }

    func didDeleteTravel() {
        self.reservedTravelUsecase.deleteTravel(of: self.travel)
        self.coordinator?.popToHome()
    }

    func travelDidUpdate(travel: Travel) {
        self.travel = travel
    }
}
