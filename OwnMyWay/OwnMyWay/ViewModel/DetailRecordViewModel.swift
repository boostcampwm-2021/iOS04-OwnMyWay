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

    func bind(errorHandler: @escaping (Error) -> Void)
    func didTouchBackButton()
    func didTouchDeleteButton()
    func didTouchEditButton()
    func didUpdateRecord(record: Record)
}

protocol DetailRecordCoordinatingDelegate: AnyObject {
    func pushToAddRecord(record: Record)
    func popToParent(with travel: Travel, isPopable: Bool)
}

class DefaultDetailRecordViewModel: DetailRecordViewModel {

    var recordPublisher: Published<Record>.Publisher { $record }

    @Published private(set) var record: Record
    private var travel: Travel

    private let usecase: DetailRecordUsecase
    private weak var coordinatingDelegate: DetailRecordCoordinatingDelegate?
    private var errorHandler: ((Error) -> Void)?

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

    func bind(errorHandler: @escaping (Error) -> Void) {
        self.errorHandler = errorHandler
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToParent(with: self.travel, isPopable: false)
    }

    func didTouchEditButton() {
        self.coordinatingDelegate?.pushToAddRecord(record: self.record)
    }

    func didUpdateRecord(record: Record) {
        self.record = record
        switch self.usecase.executeRecordUpdate(record: record) {
        case .success:
            guard let index = self.travel.records.firstIndex(where: { $0.uuid == record.uuid })
            else {
                self.errorHandler?(RepositoryError.uuidError)
                return
            }
            self.travel.records[index] = record
        case .failure(let error):
            self.errorHandler?(error)
        }
    }

    func didTouchDeleteButton() {
        switch self.usecase.executeRecordDeletion(at: self.record) {
        case .success:
            guard let index = self.travel.records.firstIndex(where: { $0 == self.record }) else {
                self.errorHandler?(ModelError.recordError)
                return
            }
            self.travel.records.remove(at: index)
            self.coordinatingDelegate?.popToParent(with: self.travel, isPopable: true)
        case .failure(let error):
            self.errorHandler?(error)
        }
    }
}
