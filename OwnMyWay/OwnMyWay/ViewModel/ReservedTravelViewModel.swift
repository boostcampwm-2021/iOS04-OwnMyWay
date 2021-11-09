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
    func didDeleteTravel()
    func didUpdateTravel(to travel: Travel)
}

protocol ReservedTravelCoordinatingDelegate: AnyObject {
    func popToHome()
}

class DefaultReservedTravelViewModel: ReservedTravelViewModel, ObservableObject {
    private(set) var travel: Travel
    private(set) var isPossibleStart: Bool

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
        self.usecase.executeDeletion(of: self.travel)
        self.coordinatingDelegate?.popToHome()
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel
        // TODO: usecase -> repository update 구현해야함
    }
}
