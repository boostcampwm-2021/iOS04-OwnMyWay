//
//  CompleteEditingUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol CompleteEditingUsecase {
    func executeUpdate(travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void)
}
