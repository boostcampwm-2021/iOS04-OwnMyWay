//
//  OngoingViewModel.swift.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol OngoingViewModel {

}

protocol OngoingCoordinatingDelegate: AnyObject {

}

class DefaultOngoingViewModel: OngoingViewModel {

    private let usecase: OngoingUsecase
    private weak var coordinatingDelegate: OngoingCoordinatingDelegate?

    init(
        usecase: OngoingUsecase,
        coordinatingDelegate: OngoingCoordinatingDelegate
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

}
