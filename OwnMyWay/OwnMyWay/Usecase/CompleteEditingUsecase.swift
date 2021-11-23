//
//  CompleteEditingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Foundation

protocol CompleteEditingUsecase {
    func executeUpdate(travel: Travel) -> Result<Void, Error>
}

struct DefaultCompleteEditingUsecase: CompleteEditingUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeUpdate(travel: Travel) -> Result<Void, Error> {
        switch self.repository.update(travel: travel) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

}
