//
//  OutdatedTravelViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol OutdatedTravelViewModel {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }

    func didTouchBackButton()
}

protocol OutdatedTravelCoordinatingDelegate: AnyObject {
    func popToHome()
}

class DefaultOutdatedTravelViewModel: OutdatedTravelViewModel {
    @Published private(set) var travel: Travel
    var travelPublisher: Published<Travel>.Publisher { $travel }

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

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToHome()
    }
}
