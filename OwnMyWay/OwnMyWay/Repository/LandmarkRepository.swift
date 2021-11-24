//
//  LandmarkDTORepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation
import UIKit

enum JSONError: Error {
    case assetError
    case decodeError
}

protocol LandmarkRepository {
    func fetchLandmarks(completion: @escaping (Result<[Landmark], Error>) -> Void)
}

class LocalJSONLandmarkRepository: LandmarkRepository {

    func fetchLandmarks(completion: @escaping (Result<[Landmark], Error>) -> Void) {
        guard let jsonFile = NSDataAsset.init(name: "landmark")
        else {
            completion(.failure(JSONError.assetError))
            return
        }

        do {
            let landmarkDTOs = try JSONDecoder()
                .decode([LandmarkDTO].self, from: jsonFile.data)
            completion(.success(landmarkDTOs.map { $0.toLandmark() }))
        } catch {
            completion(.failure(JSONError.decodeError))
        }
    }

}
