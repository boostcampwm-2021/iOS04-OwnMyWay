//
//  LandmarkRepository.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol LandmarkRepository {
    func fetchLandmarks(completion: @escaping (Result<[Landmark], Error>) -> Void)
}
