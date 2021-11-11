//
//  OngoingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol OngoingTravelUsecase {
    func executeFetch()
    func executeFinishingTravel()
    func executeFlagUpdate(of travel: Travel)
    func executeLocationUpdate(of travel: Travel, latitude: Double, longitude: Double)
}

struct DefaultOngoingTravelUsecase: OngoingTravelUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeFetch() {}
    func executeFinishingTravel() {}

    func executeFlagUpdate(of travel: Travel) {
        self.repository.update(travel: travel)
    }

    func executeLocationUpdate(of travel: Travel, latitude: Double, longitude: Double) {
        self.repository.addLocation(
            to: travel, latitude: latitude, longitude: longitude
        )
    }

}
