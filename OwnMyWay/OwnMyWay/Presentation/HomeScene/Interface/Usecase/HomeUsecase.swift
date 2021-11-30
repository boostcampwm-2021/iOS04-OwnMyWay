//
//  HomeUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol HomeUsecase {
    func executeFetch(completion: @escaping (Result<[Travel], Error>) -> Void)
}
