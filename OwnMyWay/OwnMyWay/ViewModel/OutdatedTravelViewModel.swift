//
//  OutdatedTravelViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol OutdatedTravelViewModel {

}

protocol OutdatedTravelCoordinatingDelegate: AnyObject {

}

class DefaultOutdatedTravelViewModel: OutdatedTravelViewModel {

    private var travel: Travel
    private let usecase: OutdatedTravelUsecase
    private weak var coordinatingDelegate: OutdatedTravelCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: OutdatedTravelUsecase,
        coordinatingDelegate: OutdatedTravelCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

}
