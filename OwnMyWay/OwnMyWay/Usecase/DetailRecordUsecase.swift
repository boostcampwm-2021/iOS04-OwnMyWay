//
//  DetailRecordUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Foundation

protocol DetailRecordUsecase {
    func executeRecordUpdate(record: Record)
    func executeRecordDeletion(at record: Record)
}

struct DefaultDetailRecordUsecase: DetailRecordUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeRecordUpdate(record: Record) {
        self.repository.updateRecord(at: record)
    }

    func executeRecordDeletion(at record: Record) {
        self.repository.deleteRecord(at: record)
    }
}
