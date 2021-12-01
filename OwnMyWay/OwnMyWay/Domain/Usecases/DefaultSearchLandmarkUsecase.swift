//
//  SearchLandmarkUsecase.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation

struct DefaultSearchLandmarkUsecase: SearchLandmarkUsecase {

    private let repository: LandmarkRepository

    init(repository: LandmarkRepository) {
        self.repository = repository
    }

    func executeFetch(completion: @escaping (Result<[Landmark], Error>) -> Void) {
        repository.fetchLandmarks { result in
            completion(result)
        }
    }

    func executeSearch(by text: String, completion: @escaping (Result<[Landmark], Error>) -> Void) {
        repository.fetchLandmarks { result in
            switch result {
            case .success(let landmarks):
                let searchResult = landmarks.filter {
                    guard let title = $0.title
                    else { return false }
                    return title.contains(text)
                }
                completion(.success(searchResult))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
