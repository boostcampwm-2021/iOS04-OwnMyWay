//
//  StartedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol StartedTravelUsecase {
    func executeFetch()
    func executeFinishingTravel()
    func executeFlagUpdate(of travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void)
    func executeDeletion(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
    func executeLocationUpdate(
        of travel: Travel, latitude: Double, longitude: Double,
        completion: @escaping (Result<Location, Error>) -> Void
    )
    func executeRecordAddition(
        to travel: Travel, with record: Record,
        completion: @escaping (Result<Travel, Error>) -> Void
    )
}
