//
//  Coordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
