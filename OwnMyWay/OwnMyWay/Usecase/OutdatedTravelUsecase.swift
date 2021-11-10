//
//  OutdatedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol OutdatedTravelUsecase {

}

struct DefaultOutdatedTravelUsecase: OutdatedTravelUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

}
