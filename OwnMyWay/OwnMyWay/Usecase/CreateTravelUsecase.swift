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
    func makeTravel(title: String,
                    startDate: Date,
                    endDate: Date,
                    completion: @escaping (Travel) -> Void)
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

    func makeTravel(title: String,
                    startDate: Date,
                    endDate: Date,
                    completion: @escaping (Travel) -> Void) {
            switch self.travelRepository.addTravel(title: title,
                                                       startDate: startDate,
                                                   endDate: endDate) {
            case .success(let travel):
                completion(travel)
            case .failure(let error):
                print(error)
            }
    }
}
