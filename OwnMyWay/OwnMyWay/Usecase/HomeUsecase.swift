//
//  HomeUsecase.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import Foundation

protocol HomeUsecase {
    func executeFetch(completion: @escaping ([Travel]) -> Void)
}

class DefaultHomeUsecase: HomeUsecase {

    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository) {
        self.travelRepository = travelRepository
    }

    func executeFetch(completion: @escaping ([Travel]) -> Void) {
        let result = travelRepository.fetchAllTravels()
        switch result {
        case .success(let travels):
            completion(travels)
        case .failure(let error):
            print(error)
        }
    }

}
