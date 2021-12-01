//
//  CreateTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Foundation

struct DefaultEnterTitleUsecase: EnterTitleUsecase {

    func executeTitleValidation(
        with title: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if !title.isEmpty {
            completion(.success(title))
        } else {
            completion(.failure(EnterTitleError.nilTitle))
        }
    }
}
