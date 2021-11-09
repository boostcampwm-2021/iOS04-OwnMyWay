//
//  ReservedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

protocol ReservedTravelUsecase {
    func executeDeletion(of travel: Travel)
}

class DefaultReservedTravelUsecase: ReservedTravelUsecase {

    let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeDeletion(of travel: Travel) {
        self.repository.delete(travel: travel)
    }
}
