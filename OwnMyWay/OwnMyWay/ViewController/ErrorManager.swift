//
//  ErrorManager.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/23.
//

import UIKit

class ErrorManager {
    static func showAlert(with error: Error, to viewController: UIViewController?) {
        viewController?.showToast(message: error.localizedDescription)
    }
}

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
