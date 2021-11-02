//
//  SearchLandmarkUsecase.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation

protocol SearchLandmarkUsecase {
    func executeFetch(completion: @escaping ([LandmarkDTO]) -> Void)
}

class DefaultSearchLandmarkUsecase: SearchLandmarkUsecase {

    let landmarkDTORepository: LandmarkDTORepository

    init(landmarkDTORepository: LandmarkDTORepository) {
        self.landmarkDTORepository = landmarkDTORepository
    }

    func executeFetch(completion: @escaping ([LandmarkDTO]) -> Void) {
        landmarkDTORepository.fetchLandmarkDTOs { result in
            switch result {
            case .success(let landmarkDTOs):
                completion(landmarkDTOs)
            case .failure(let error):
                print(error)
            }
        }
    }

}
