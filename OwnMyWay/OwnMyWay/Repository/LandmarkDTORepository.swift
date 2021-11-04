//
//  LandmarkDTORepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation
import UIKit

protocol LandmarkDTORepository {
    func fetchLandmarkDTOs(completion: @escaping (Result<[Landmark], Error>) -> Void)
}

class DefaultLandmarkDTORepository: LandmarkDTORepository {

    func fetchLandmarkDTOs(completion: @escaping (Result<[Landmark], Error>) -> Void) {
        guard let jsonFile = NSDataAsset.init(name: "landmark") else {
            return
        }
        do {
            let landmarkDTOs = try JSONDecoder().decode([LandmarkDTO].self,
                                                        from: jsonFile.data)
            completion(.success(landmarkDTOs.map { $0.toLandmark() }))
        } catch let error {
            completion(.failure(error))
        }
    }

}
