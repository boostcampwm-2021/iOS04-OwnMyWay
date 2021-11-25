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
    var errorPublisher: Published<Error?>.Publisher { get }

    func didTouchBackButton()
    func didTouchDeleteButton()
    func didTouchEditButton()
    func didUpdateRecord(record: Record)
    func didTouchImageView(index: Int)
}

protocol DetailRecordCoordinatingDelegate: AnyObject {
    func pushToAddRecord(record: Record)
    func popToParent(with travel: Travel, isPopable: Bool)
    func presentDetailImage(images: [URL], index: Int)
}

class DefaultDetailRecordViewModel: DetailRecordViewModel {

    var recordPublisher: Published<Record>.Publisher { $record }
    var errorPublisher: Published<Error?>.Publisher { $error }

    @Published private(set) var record: Record
    @Published private var error: Error?
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

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToParent(with: self.travel, isPopable: false)
    }

    func didTouchEditButton() {
        self.coordinatingDelegate?.pushToAddRecord(record: self.record)
    }

    func didUpdateRecord(record: Record) {
        self.record = record
        self.usecase.executeRecordUpdate(record: record) { [weak self] result in
            switch result {
            case .success:
                guard self?.travel.records.firstIndex(where: { $0.uuid == record.uuid }) != nil
                else {
                    self?.error = RepositoryError.uuidError
                    return
                }
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didTouchDeleteButton() {
        self.usecase.executeRecordDeletion(at: self.record) { [weak self] result in
            switch result {
            case .success:
                guard let index = self?.travel.records.firstIndex(where: { $0 == self?.record })
                else {
                    self?.error = ModelError.recordError
                    return
                }
                self?.travel.records.remove(at: index)
                guard let travel = self?.travel else { return }
                self?.coordinatingDelegate?.popToParent(with: travel, isPopable: true)
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didTouchImageView(index: Int) {
        guard let images = self.record.photoURLs else { return }
        self.coordinatingDelegate?.presentDetailImage(images: images, index: index)
    }
}
