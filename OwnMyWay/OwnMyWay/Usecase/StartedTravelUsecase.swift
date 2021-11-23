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
    func executeFlagUpdate(of travel: Travel) -> Result<Void, Error>
    func executeDeletion(of travel: Travel) -> Result<Void, Error>
    func executeLocationUpdate(
        of travel: Travel, latitude: Double, longitude: Double
    ) -> Result<Void, Error>
    func executeRecordAddition(to travel: Travel, with record: Record, completion: (Travel) -> Void)
}

struct DefaultStartedTravelUsecase: StartedTravelUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeFetch() {}
    func executeFinishingTravel() {}

    func executeDeletion(of travel: Travel) -> Result<Void, Error> {
        return self.repository.delete(travel: travel)
    }

    func executeFlagUpdate(of travel: Travel) -> Result<Void, Error> {
        switch self.repository.update(travel: travel) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    func executeLocationUpdate(
        of travel: Travel, latitude: Double, longitude: Double
    ) -> Result<Void, Error> {
        switch self.repository.addLocation(
            to: travel, latitude: latitude, longitude: longitude
        ) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
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
