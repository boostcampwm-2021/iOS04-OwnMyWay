//
//  SearchLocationViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/18.
//

import Combine
import Foundation

protocol SearchLocationViewModel {
    func didSelectLocation(title: String?, latitude: Double, longitude: Double)
}

protocol SearchLocationCoordinatingDelegate: AnyObject {
    func dismissToAddRecord(title: String?, latitude: Double, longitude: Double)
}

class DefaultSearchLocationViewModel: SearchLocationViewModel {

    private weak var coordinatingDelegate: SearchLocationCoordinatingDelegate?

    init(
        coordinatingDelegate: SearchLocationCoordinatingDelegate
    ) {
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didSelectLocation(title: String?, latitude: Double, longitude: Double) {
        self.coordinatingDelegate?.dismissToAddRecord(
            title: title, latitude: latitude, longitude: longitude
        )
    }
}
