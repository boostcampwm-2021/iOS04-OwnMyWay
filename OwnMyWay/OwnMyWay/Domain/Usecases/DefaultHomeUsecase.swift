//
//  HomeUsecase.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import Foundation

struct DefaultHomeUsecase: HomeUsecase {

    let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeFetch(completion: @escaping (Result<[Travel], Error>) -> Void) {
        self.repository.fetchAllTravels { result in
            completion(result)
        }
    }
}
