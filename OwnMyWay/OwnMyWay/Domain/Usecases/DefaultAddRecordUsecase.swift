//
//  AddRecordUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

struct DefaultAddRecordUsecase: AddRecordUsecase {

    private let repository: TravelRepository
    private let imageFileManager: ImageFileManager

    init(repository: TravelRepository, imageFileManager: ImageFileManager) {
        self.repository = repository
        self.imageFileManager = imageFileManager
    }

    func executeValidationTitle(with title: String?) -> Bool {
        return (1...20) ~= (title ?? "").count
    }

    func executeValidationDate(with date: Date?) -> Bool {
        return date != nil
    }

    func executeValidationCoordinate(with coordinate: Location) -> Bool {
        guard let latitude = coordinate.latitude,
              let longitude = coordinate.longitude
        else { return false }
        return (-90...90) ~= latitude && (-180...180) ~= longitude
    }

    func executePickingPhoto(with url: URL, completion: (Result<String, Error>) -> Void) {
        self.imageFileManager.copyPhoto(from: url, completion: completion)
    }

    func executeRemovingPhoto(of photoID: String, completion: (Result<Void, Error>) -> Void) {
        self.imageFileManager.removePhoto(of: photoID) { result in
            completion(result)
        }
    }
}
