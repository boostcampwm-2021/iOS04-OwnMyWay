//
//  CompleteEditingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Foundation

struct DefaultCompleteEditingUsecase: CompleteEditingUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeUpdate(travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void) {
        self.repository.update(travel: travel) { result in
            completion(result)
        }
    }
}
