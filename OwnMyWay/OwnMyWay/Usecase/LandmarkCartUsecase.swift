//
//  LandmarkCartUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/02.
//

import Foundation

enum LandmarkCartError: Error {
    case registerFail
}

protocol LandmarkCartUsecase {
    func addLandmark(to travel: Travel, of landmark: Landmark, completion: (Landmark) -> Void)
}

class DefaultLandmarkCartUsecase: LandmarkCartUsecase {
    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository) {
        self.travelRepository = travelRepository
    }

    func addLandmark(to travel: Travel, of landmark: Landmark, completion: (Landmark) -> Void) {
        let result = self.travelRepository.addLandmark(
            to: travel,
            title: landmark.title,
            image: landmark.image,
            latitude: landmark.latitude,
            longitude: landmark.longitude
        )

        switch result {
        case .success(let createLandmark):
            completion(createLandmark)
        case .failure(let error):
            print(error)
        }
    }
}
