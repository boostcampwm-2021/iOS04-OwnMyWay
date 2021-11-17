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
    private var travel: Travel?

    init(navigationController: UINavigationController, travel: Travel?) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let usecase = DefaultCreateTravelUsecase()
        let createTravelVM = DefaultCreateTravelViewModel(
            usecase: usecase,
            coordinatingDelegate: self,
            travel: self.travel
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
