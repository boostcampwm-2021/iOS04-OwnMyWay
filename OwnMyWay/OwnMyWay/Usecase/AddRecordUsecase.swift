//
//  AddRecordUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol AddRecordUsecase {

}

struct DefaultAddRecordUsecase: AddRecordUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

}
