//
//  OngoingUsecase.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol OngoingUsecase {

}

struct DefaultOngoingUsecase: OngoingUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

}
