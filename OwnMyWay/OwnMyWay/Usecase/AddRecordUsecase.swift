//
//  AddRecordUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol AddRecordUsecase {
    func executeValidationTitle(with title: String?) -> Bool
    func executeValidationDate(with date: Date?) -> Bool
}

struct DefaultAddRecordUsecase: AddRecordUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeValidationTitle(with title: String?) -> Bool {
        return (1...20) ~= (title ?? "").count
    }

    func executeValidationDate(with date: Date?) -> Bool {
        return date != nil
    }

}
