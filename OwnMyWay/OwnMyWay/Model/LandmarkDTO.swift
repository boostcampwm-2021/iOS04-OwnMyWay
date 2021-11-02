//
//  LandmarkDTO.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/02.
//

import Foundation

// MARK:- LandmarkDTO: JSON에서 뽑아주는 Landmark 형식, CoreData에서 사용하는 형식과 다름
struct LandmarkDTO: Codable {
    let id: Int
    let title: String
    let image: String
    let latitude, longitude: Double
}
