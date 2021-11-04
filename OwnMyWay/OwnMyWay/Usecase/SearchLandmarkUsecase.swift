//
//  SearchLandmarkUsecase.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation

protocol SearchLandmarkUsecase {
    func executeFetch(completion: @escaping ([Landmark]) -> Void)
    func executeSearch(searchText: String, completion: @escaping ([Landmark]) -> Void)
}

class DefaultSearchLandmarkUsecase: SearchLandmarkUsecase {

    let landmarkDTORepository: LandmarkDTORepository

    init(landmarkDTORepository: LandmarkDTORepository) {
        self.landmarkDTORepository = landmarkDTORepository
    }

    func executeFetch(completion: @escaping ([Landmark]) -> Void) {
        landmarkDTORepository.fetchLandmarkDTOs { result in
            switch result {
            case .success(let landmarks):
                completion(landmarks)
            case .failure(let error):
                print(error)
            }
        }
    }

    func executeSearch(searchText: String, completion: @escaping ([Landmark]) -> Void) {
        landmarkDTORepository.fetchLandmarkDTOs { result in
            switch result {
            case .success(let landmarkDTOs):
                let searchResult = landmarkDTOs.filter {
                    guard let title = $0.title else { return false }
                    return title.contains(searchText)
                }
                completion(searchResult)
            case .failure(let error):
                print(error)
            }
        }
    }

}
