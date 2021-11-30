//
//  RepositoryError.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

enum RepositoryError: Error, LocalizedError {
    case saveError
    case fetchError
    case uuidError
    case locationError
    case recordError
    case landmarkError

    var errorDescription: String? {
        switch self {
        case .saveError:
            return "저장에 실패했어요."
        case .fetchError:
            return "저장에 실패했어요."
        case .uuidError:
            return "저장에 실패했어요."
        case .locationError:
            return "위치 저장에 실패했어요."
        case .recordError:
            return "게시물 저장에 실패했어요."
        case .landmarkError:
            return "관광명소 저장에 실패했어요."
        }
    }
}
