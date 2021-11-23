//
//  ReservedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

protocol ReservedTravelUsecase {
    func executeDeletion(of travel: Travel) -> Result<Void, Error>
    func executeLandmarkAddition(of travel: Travel)
    func executeLandmarkDeletion(at landmark: Landmark) -> Result<Void, Error>
    func executeFlagUpdate(of travel: Travel) -> Result<Void, Error>
}

struct DefaultReservedTravelUsecase: ReservedTravelUsecase {

    let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeDeletion(of travel: Travel) -> Result<Void, Error> {
        return self.repository.delete(travel: travel)
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

    func executeLandmarkDeletion(at landmark: Landmark) -> Result<Void, Error> {
        return self.repository.deleteLandmark(at: landmark)
    }

    func executeFlagUpdate(of travel: Travel) -> Result<Void, Error> {
        switch self.repository.update(travel: travel) {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
