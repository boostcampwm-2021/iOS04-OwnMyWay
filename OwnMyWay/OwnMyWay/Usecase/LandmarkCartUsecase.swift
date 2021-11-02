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
    func addLandmark(to travel: Travel, of landmark: Landmark, completion: (Error) -> Void)
    func delete(of travel: Travel)
    func delete(of landmark: Landmark)
}

class DefaultLandmarkCartUsecase: LandmarkCartUsecase {
    let travelRepository: TravelRepository

    init(travelRepository: TravelRepository) {
        self.travelRepository = travelRepository
    }

    func addLandmark(to travel: Travel, of landmark: Landmark, completion: (Error) -> Void) {
        guard let title = landmark.title, let image = landmark.image else { return }
        let latitude = landmark.latitude, longitude = landmark.longitude

        let result = self.travelRepository.addLandmark(to: travel,
                                                       title: title,
                                                       image: image,
                                                       latitude: latitude,
                                                       longitude: longitude)
        switch result {
        case .success: break
        case .failure: completion(LandmarkCartError.registerFail)
        }
    }

    func delete(of travel: Travel) {
        // self.travelRepository.deleteTravel()
        // 구현해주세요 우재님 ^_^
    }

    func delete(of landmark: Landmark) {
//        self.travelRepository.deleteLandmark()
//        구현해주세요 우재님 ^_^
    }
}
