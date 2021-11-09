//
//  SearchLandmarkUsecase.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation

protocol SearchLandmarkUsecase {
    func executeFetch(completion: @escaping ([Landmark]) -> Void)
    func executeSearch(by text: String, completion: @escaping ([Landmark]) -> Void)
}

struct DefaultSearchLandmarkUsecase: SearchLandmarkUsecase {

    private let repository: LandmarkRepository

    init(repository: LandmarkRepository) {
        self.repository = repository
    }

    func executeFetch(completion: @escaping ([Landmark]) -> Void) {
        repository.fetchLandmarks { result in
            switch result {
            case .success(let landmarks):
                completion(landmarks)
            case .failure(let error):
                print(error)
            }
        }
    }

    func executeSearch(by text: String, completion: @escaping ([Landmark]) -> Void) {
        repository.fetchLandmarks { result in
            switch result {
            case .success(let landmarkDTOs):
                let searchResult = landmarkDTOs.filter {
                    guard let title = $0.title
                    else { return false }
                    return title.contains(text)
                }
                completion(searchResult)
            case .failure(let error):
                print(error)
            }
        }
    }

}
