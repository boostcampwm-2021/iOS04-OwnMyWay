//
//  DetailRecordUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Foundation

struct DefaultDetailRecordUsecase: DetailRecordUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

    func executeRecordUpdate(record: Record, completion: @escaping (Result<Void, Error>) -> Void) {
        self.repository.updateRecord(at: record) { result in
            completion(result)
        }
    }

    func executeRecordDeletion(at record: Record,
                               completion: @escaping ( Result<Void, Error>) -> Void
    ) {
        self.repository.deleteRecord(at: record) { result in
            completion(result)
        }
    }
}
