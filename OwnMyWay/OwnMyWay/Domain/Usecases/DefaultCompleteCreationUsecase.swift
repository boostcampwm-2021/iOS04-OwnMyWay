//
//  CompleteCreationUsecase.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import Foundation

struct DefaultCompleteCreationUsecase: CompleteCreationUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeCreation(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {
        self.repository.save(travel: travel) { result in
            completion(result)
        }
    }

}
