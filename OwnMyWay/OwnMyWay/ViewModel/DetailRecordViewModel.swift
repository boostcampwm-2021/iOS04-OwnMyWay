//
//  DetailRecordViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Foundation

protocol DetailRecordViewModel {
    var record: Record { get }
    var recordPublisher: Published<Record>.Publisher { get }
}

protocol DetailRecordCoordinatingDelegate: AnyObject { }

class DefaultDetailRecordViewModel: DetailRecordViewModel {

    var recordPublisher: Published<Record>.Publisher { $record }

    @Published private(set) var record: Record

    private let usecase: DetailRecordUsecase
    private weak var coordinatingDelegate: DetailRecordCoordinatingDelegate?

    init(
        record: Record,
        usecase: DetailRecordUsecase,
        coordinatingDelegate: DetailRecordCoordinatingDelegate
    ) {
        self.record = record
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }
}
