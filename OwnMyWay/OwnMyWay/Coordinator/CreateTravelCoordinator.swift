//
//  CreateTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class CreateTravelCoordinator: Coordinator, CreateTravelCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }

    func start() {
        let usecase = DefaultCreateTravelUsecase()
        let createTravelVM = DefaultCreateTravelViewModel(
            usecase: usecase,
            coordinatingDelegate: self
        )
        let createTravelVC = CreateTravelViewController.instantiate(storyboardName: "CreateTravel")
        createTravelVC.bind(viewModel: createTravelVM)
        self.navigationController.pushViewController(createTravelVC, animated: true)
    }

    func pushToAddLandmark(travel: Travel) {
        let addLandmarkCoordinator = AddLandmarkCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(addLandmarkCoordinator)
        addLandmarkCoordinator.start()
    }
}
