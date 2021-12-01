//
//  CompleteCreationUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol CompleteCreationUsecase {
    func executeCreation(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
}
