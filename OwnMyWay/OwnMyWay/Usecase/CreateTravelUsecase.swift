//
//  CreateTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Foundation

enum CreateTravelError: Error {
    case nilTitle
    case impossibleTravel
}

protocol CreateTravelUsecase {
    func configTravelTitle(text: String,
                           completion: @escaping (Result<String, Error>) -> Void)
    func configTravelDate(startDate: Date,
                          endDate: Date,
                          completion: @escaping (Date, Date) -> Void)
    func makeTravel(isPossible: Bool,
                    title: String,
                    startDate: Date,
                    endDate: Date,
                    completion: @escaping (Result<Travel, Error>) -> Void)
}

class DefaultCreateTravelUsecase: CreateTravelUsecase {

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository) {
        self.travelRepository = travelRepository
    }

    func configTravelTitle(text: String,
                           completion: @escaping (Result<String, Error>) -> Void) {
        if !text.isEmpty {
            completion(.success(text))
        } else {
            completion(.failure(CreateTravelError.nilTitle))
        }
    }

    func configTravelDate(startDate: Date,
                          endDate: Date,
                          completion: @escaping (Date, Date) -> Void) {
        completion(startDate, endDate) // 아무런 역할도 하지 않아요
    }

    func makeTravel(isPossible: Bool,
                    title: String,
                    startDate: Date,
                    endDate: Date,
                    completion: @escaping (Result<Travel, Error>) -> Void) {
        if isPossible {
            completion(self.travelRepository.addTravel(title: title,
                                                       startDate: startDate,
                                                       endDate: endDate))
        } else {
            completion(.failure(CreateTravelError.impossibleTravel))
        }
    }
}
