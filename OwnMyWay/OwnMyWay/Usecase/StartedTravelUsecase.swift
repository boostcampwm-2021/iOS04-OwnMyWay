//
//  OngoingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol StartedTravelUsecase {
    func executeFetch()
    func executeFinishingTravel()
    func executeFlagUpdate(of travel: Travel)
    func executeLocationUpdate(of travel: Travel, latitude: Double, longitude: Double)
    func executeRecordAddition(to travel: Travel, with record: Record, completion: (Travel) -> Void)
}

struct DefaultStartedTravelUsecase: StartedTravelUsecase {

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

    func executeRecordAddition(
        to travel: Travel, with record: Record, completion: (Travel) -> Void
    ) {
        switch self.repository.addRecord(to: travel, with: record) {
        case .success(let newTravel):
            completion(newTravel)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
}
