//
//  TravelRepository.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol TravelRepository {
    func fetchAllTravels(completion: @escaping (Result<[Travel], Error>) -> Void)
    func addTravel(
        title: String, startDate: Date, endDate: Date,
        completion: @escaping (Result<Travel, Error>) -> Void
    )
    func save(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
    func addLandmark(
        to travel: Travel, uuid: UUID?, title: String?,
        image: URL?, latitude: Double?, longitude: Double?,
        completion: @escaping (Result<Landmark, Error>) -> Void
    )
    func addRecord(
        to travel: Travel, with record: Record,
        completion: @escaping (Result<Travel, Error>) -> Void
    )
    func addLocation(
        to travel: Travel, latitude: Double?, longitude: Double?,
        completion: @escaping (Result<Location, Error>) -> Void
    )
    func update(travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void)
    func updateRecord(at record: Record, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteLandmark(at landmark: Landmark, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteRecord(at record: Record, completion: @escaping (Result<Void, Error>) -> Void)
}
