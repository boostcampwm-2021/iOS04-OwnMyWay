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

class ReservedTravelViewModel: ReservedTravelViewModelType, ObservableObject {
    var travel: Travel
    var isPossibleStart: Bool

    private let reservedTravelUsecase: ReservedTravelUsecase

    init(reservedTravelUsecase: ReservedTravelUsecase, travel: Travel) {
        self.travel = travel
        self.reservedTravelUsecase = reservedTravelUsecase
        self.isPossibleStart = travel.startDate == Date()
    }

    func didDeleteTravel() {
        self.reservedTravelUsecase.deleteTravel(of: self.travel)
    }

    func travelDidUpdate(travel: Travel) {
        self.travel = travel
    }
}
