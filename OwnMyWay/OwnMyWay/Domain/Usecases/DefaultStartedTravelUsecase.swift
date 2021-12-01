//
//  OngoingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

struct DefaultStartedTravelUsecase: StartedTravelUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeFetch(of travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void) {
        self.repository.fetchTravel(of: travel) { result in
            completion(result)
        }
    }

    func executeFlagUpdate(of travel: Travel,
                           completion: @escaping (Result<Travel, Error>) -> Void
    ) {
        self.repository.update(travel: travel) { result in
            completion(result)
        }
    }

    func executeDeletion(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {
        self.repository.delete(travel: travel) { result in
            completion(result)
        }
    }

    func executeLocationUpdate(
        of travel: Travel, latitude: Double, longitude: Double,
        completion: @escaping (Result<Location, Error>) -> Void
    ) {
        self.repository.addLocation(
            to: travel, latitude: latitude, longitude: longitude
        ) { result in
            completion(result)
        }
    }

    func executeRecordAddition(
        to travel: Travel, with record: Record,
        completion: @escaping (Result<Travel, Error>) -> Void
    ) {
        self.repository.addRecord(to: travel, with: record) { result in
            completion(result)
        }
    }
}
