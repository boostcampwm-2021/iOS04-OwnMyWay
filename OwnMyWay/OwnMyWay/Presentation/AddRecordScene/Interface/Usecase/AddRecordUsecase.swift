//
//  AddRecordUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol AddRecordUsecase {
    func executeValidationTitle(with title: String?) -> Bool
    func executeValidationDate(with date: Date?) -> Bool
    func executeValidationCoordinate(with coordinate: Location) -> Bool
    func executePickingPhoto(with url: URL, completion: (Result<String, Error>) -> Void)
    func executeRemovingPhoto(of photoID: String, completion: (Result<Void, Error>) -> Void)
}
