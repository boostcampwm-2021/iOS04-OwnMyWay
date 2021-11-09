//
//  CompleteCreationUsecase.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import Foundation

protocol CompleteCreationUsecase {
    func executeCreation(travel: Travel)
}

struct DefaultCompleteCreationUsecase: CompleteCreationUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeCreation(travel: Travel) {
        self.repository.save(travel: travel)
    }

}
