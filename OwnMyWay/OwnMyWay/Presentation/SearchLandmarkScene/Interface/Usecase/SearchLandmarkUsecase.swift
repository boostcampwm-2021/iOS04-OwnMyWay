//
//  SearchLandmarkUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol SearchLandmarkUsecase {
    func executeFetch(completion: @escaping (Result<[Landmark], Error>) -> Void)
    func executeSearch(by text: String, completion: @escaping (Result<[Landmark], Error>) -> Void)
}
