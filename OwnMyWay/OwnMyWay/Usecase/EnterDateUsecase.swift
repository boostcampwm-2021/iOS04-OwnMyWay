//
//  EnterDateUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/23.
//

import Foundation

protocol EnterDateUsecase {
    func executeEnteringDate(firstDate: Date, secondDate: Date, completion: ([Date]) -> Void)
}

struct DefaultEnterDateUsecase: EnterDateUsecase {
    func executeEnteringDate(firstDate: Date, secondDate: Date, completion: ([Date]) -> Void) {
        completion(Array(Set([firstDate, secondDate])).sorted())
    }
}
