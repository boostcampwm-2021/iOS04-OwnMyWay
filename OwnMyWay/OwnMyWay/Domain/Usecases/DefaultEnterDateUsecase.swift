//
//  EnterDateUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/23.
//

import Foundation

struct DefaultEnterDateUsecase: EnterDateUsecase {
    func executeEnteringDate(firstDate: Date, secondDate: Date, completion: ([Date]) -> Void) {
        completion(Array(Set([firstDate, secondDate])).sorted())
    }
}
