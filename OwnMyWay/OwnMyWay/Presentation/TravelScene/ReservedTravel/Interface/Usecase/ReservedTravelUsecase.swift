//
//  ReservedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol ReservedTravelUsecase {
    func executeDeletion(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
    func executeLandmarkAddition(
        of travel: Travel,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func executeLandmarkDeletion(
        at landmark: Landmark,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func executeFlagUpdate(
        of travel: Travel,
        completion: @escaping (Result<Travel, Error>) -> Void
    )
}
