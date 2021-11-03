//
//  Coordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import UIKit

protocol AppCoordinator {
    func start()
}

protocol HomeCoordinator {
    func pushToCreateTravel()
}

protocol CreateTravelCoordinator {
    func pushToAddLandmark()
}

class DefaultCoordinator: AppCoordinator, HomeCoordinator, CreateTravelCoordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let homeVC = HomeViewController.instantiate(storyboardName: "Home")
        homeVC.coordinator = self
        navigationController.pushViewController(homeVC, animated: false)
    }

    func pushToCreateTravel() {
        let createTravelVC = CreateTravelViewController.instantiate(storyboardName: "CreateTravel")
        createTravelVC.coordinator = self
        navigationController.pushViewController(createTravelVC, animated: true)
    }

    func pushToAddLandmark() {
        let addLandmarkVC = AddLandmarkViewController.instantiate(storyboardName: "AddLandmark")
        navigationController.pushViewController(addLandmarkVC, animated: true)
    }
}
