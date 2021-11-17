//
//  CompleteEditingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Foundation

protocol CompleteEditingUsecase {
    func executeUpdate(travel: Travel)
}

struct DefaultCompleteEditingUsecase: CompleteEditingUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeUpdate(travel: Travel) {
        // FIXME: 구현 요망
    }

}
