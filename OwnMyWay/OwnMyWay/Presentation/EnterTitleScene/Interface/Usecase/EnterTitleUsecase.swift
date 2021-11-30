//
//  EnterTitleUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol EnterTitleUsecase {
    func executeTitleValidation(
        with title: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}
