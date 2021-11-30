//
//  ErrorManager.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/23.
//

import UIKit

final class ErrorManager {
    static func showToast(with error: Error, to viewController: UIViewController?) {
        viewController?.showToast(message: error.localizedDescription)
    }
}
