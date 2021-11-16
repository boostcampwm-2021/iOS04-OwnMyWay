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

    func didTouchEditButton()
    func didUpdateRecord(record: Record)
}

protocol DetailRecordCoordinatingDelegate: AnyObject {
    func pushToAddRecord(record: Record)
}

class DefaultDetailRecordViewModel: DetailRecordViewModel {

    var recordPublisher: Published<Record>.Publisher { $record }

    @Published private(set) var record: Record
    private var travel: Travel

    private let usecase: DetailRecordUsecase
    private weak var coordinatingDelegate: DetailRecordCoordinatingDelegate?

    init(
        record: Record,
        travel: Travel,
        usecase: DetailRecordUsecase,
        coordinatingDelegate: DetailRecordCoordinatingDelegate
    ) {
        self.record = record
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didTouchEditButton() {
        self.coordinatingDelegate?.pushToAddRecord(record: self.record)
    }

    func didUpdateRecord(record: Record) {
        self.record = record
        self.usecase.executeRecordUpdate(record: record)

        guard let index = self.travel.records.firstIndex(where: { $0.uuid == record.uuid })
        else { return }
        self.travel.records[index] = record
    }
}
