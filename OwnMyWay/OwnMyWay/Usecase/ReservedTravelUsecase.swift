//
//  ReservedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

protocol ReservedTravelUsecase {
    func deleteTravel(of travel: Travel)
}

class DefaultReservedTravelUsecase: ReservedTravelUsecase {
    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository) {
        self.travelRepository = travelRepository
    }

    func deleteTravel(of travel: Travel) {
        self.travelRepository.deleteTravel(of: travel)
    }
}
