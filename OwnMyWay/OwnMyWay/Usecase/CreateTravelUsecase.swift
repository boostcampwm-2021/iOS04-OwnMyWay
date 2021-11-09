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
    func configureTravelTitle(
        text: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

struct DefaultCreateTravelUsecase: CreateTravelUsecase {

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository) {
        self.travelRepository = travelRepository
    }

    func configureTravelTitle(text: String,
                              completion: @escaping (Result<String, Error>) -> Void) {
        if !text.isEmpty {
            completion(.success(text))
        } else {
            completion(.failure(CreateTravelError.nilTitle))
        }
    }
}
