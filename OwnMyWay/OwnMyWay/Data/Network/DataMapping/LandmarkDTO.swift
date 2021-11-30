//
//  LandmarkDTO.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/02.
//

import Foundation

// MARK: - LandmarkDTO: JSON에서 뽑아주는 Landmark 형식, CoreData에서 사용하는 형식과 다름
struct LandmarkDTO: Decodable {
    let id: Int
    let title: String
    let image: String
    let latitude, longitude: Double

    func toLandmark() -> Landmark {
        let url = URL(string: self.image)
        return Landmark(
            uuid: UUID(),
            image: url,
            latitude: self.latitude,
            longitude: self.longitude,
            title: self.title)
    }
}
