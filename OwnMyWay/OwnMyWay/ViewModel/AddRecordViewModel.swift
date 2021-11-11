//
//  AddRecordViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Foundation

protocol AddRecordViewModel {

}

protocol AddRecordCoordinatingDelegate: AnyObject {

}

class DefaultAddRecordViewModel: AddRecordViewModel {

    private var travel: Travel
    private let usecase: AddRecordUsecase
    private weak var coordinatingDelegate: AddRecordCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: AddRecordUsecase,
        coordinatingDelegate: AddRecordCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

}
