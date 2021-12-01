//
//  LandmarkDTORepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Foundation

final class LocalJSONLandmarkRepository: LandmarkRepository {

    func fetchLandmarks(completion: @escaping (Result<[Landmark], Error>) -> Void) {
        guard let path = Bundle.main.path(forResource: "landmark", ofType: "json"),
              let jsonString = try? String(contentsOfFile: path),
              let data = jsonString.data(using: .utf8)
        else {
            completion(.failure(JSONError.fileError))
            return
        }

        do {
            let landmarkDTOs = try JSONDecoder()
                .decode([LandmarkDTO].self, from: data)
            completion(.success(landmarkDTOs.map { $0.toLandmark() }))
        } catch {
            completion(.failure(JSONError.decodeError))
        }
    }
}
