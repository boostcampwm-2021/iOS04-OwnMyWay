//
//  ReservedTravelUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Foundation

struct DefaultReservedTravelUsecase: ReservedTravelUsecase {

    let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeDeletion(of travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {
        self.repository.delete(travel: travel) { result in
            completion(result)
        }
    }

    func executeLandmarkAddition(
        of travel: Travel,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let newLandmark = travel.landmarks.last
        else {
            completion(.failure(ModelError.landmarkError))
            return
        }

        self.repository.addLandmark(
            to: travel,
            uuid: newLandmark.uuid,
            title: newLandmark.title,
            image: newLandmark.image,
            latitude: newLandmark.latitude,
            longitude: newLandmark.longitude
        ) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func executeLandmarkDeletion(
        at landmark: Landmark,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        self.repository.deleteLandmark(at: landmark) { result in
            completion(result)
        }
    }

    func executeFlagUpdate(
        of travel: Travel,
        completion: @escaping (Result<Travel, Error>) -> Void
    ) {
        self.repository.update(travel: travel) { result in
            completion(result)
        }
    }
}
