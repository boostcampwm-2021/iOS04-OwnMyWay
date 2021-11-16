//
//  DetailRecordUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Foundation

protocol DetailRecordUsecase {
    func executeRecordUpdate(record: Record)
}

struct DefaultDetailRecordUsecase: DetailRecordUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeRecordUpdate(record: Record) {
        self.repository.updateRecord(at: record)
    }
}
