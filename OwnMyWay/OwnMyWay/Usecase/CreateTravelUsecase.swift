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
    func executeTitleValidation(
        with title: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

struct DefaultCreateTravelUsecase: CreateTravelUsecase {

    func executeTitleValidation(
        with title: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if !title.isEmpty {
            completion(.success(title))
        } else {
            completion(.failure(CreateTravelError.nilTitle))
        }
    }
}
