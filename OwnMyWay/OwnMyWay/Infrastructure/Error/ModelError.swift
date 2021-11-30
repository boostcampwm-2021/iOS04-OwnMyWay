//
//  ModelError.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

enum ModelError: Error, LocalizedError {
    case landmarkError
    case recordError
    case indexError

    var errorDescription: String? {
        switch self {
        case .landmarkError:
            return "관광명소가 존재하지 않아요."
        case .recordError:
            return "게시물이 존재하지 않아요."
        case .indexError:
            return "잘못된 위치를 참조하였어요."
        }
    }
}
