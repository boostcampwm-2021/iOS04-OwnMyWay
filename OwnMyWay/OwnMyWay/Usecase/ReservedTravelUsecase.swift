//
//  ReservedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

protocol ReservedTravelUsecase {
    func executeDeletion(of travel: Travel)
    func executeLandmarkAddition(of travel: Travel)
    func executeLandmarkDeletion(at landmark: Landmark)
    func executeFlagUpdate(of travel: Travel)
}

struct DefaultReservedTravelUsecase: ReservedTravelUsecase {

    let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeDeletion(of travel: Travel) {
        self.repository.delete(travel: travel)
    }

    func executeLandmarkAddition(of travel: Travel) {
        guard let newLandmark = travel.landmarks.last
        else { return }
        self.repository.addLandmark(
            to: travel,
            uuid: newLandmark.uuid,
            title: newLandmark.title,
            image: newLandmark.image,
            latitude: newLandmark.latitude,
            longitude: newLandmark.longitude
        )
    }

    func executeLandmarkDeletion(at landmark: Landmark) {
        self.repository.deleteLandmark(at: landmark)
    }

    func executeFlagUpdate(of travel: Travel) {
        self.repository.update(travel: travel)
    }
}
