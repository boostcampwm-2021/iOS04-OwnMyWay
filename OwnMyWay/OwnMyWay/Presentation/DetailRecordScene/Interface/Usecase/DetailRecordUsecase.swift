//
//  DetailRecordUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol DetailRecordUsecase {
    func executeRecordUpdate(record: Record, completion: @escaping (Result<Void, Error>) -> Void)
    func executeRecordDeletion(
        at record: Record, completion: @escaping (Result<Void, Error>) -> Void
    )
}
