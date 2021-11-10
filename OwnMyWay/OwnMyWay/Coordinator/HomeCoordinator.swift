//
//  HomeCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class HomeCoordinator: Coordinator, HomeCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultHomeUsecase(repository: repository)
        let homeVM = DefaultHomeViewModel(usecase: usecase, coordinatingDelegate: self)
        let homeVC = HomeViewController.instantiate(storyboardName: "Home")
        homeVC.bind(viewModel: homeVM)
        navigationController.pushViewController(homeVC, animated: false)
    }

    func pushToCreateTravel() {
        let createTravelCoordinator = CreateTravelCoordinator(
            navigationController: self.navigationController
        )
        self.childCoordinators.append(createTravelCoordinator)
        createTravelCoordinator.start()
    }

    func pushToReservedTravel(travel: Travel) {
        let reservedTravelCoordinator = ReservedTravelCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(reservedTravelCoordinator)
        reservedTravelCoordinator.start()
    }

    func pushToOngoingTravel(travel: Travel) {
        let ongoingCoordinator = OngoingCoordinator(
            navigationController: self.navigationController, travel: travel
        )
        self.childCoordinators.append(ongoingCoordinator)
        ongoingCoordinator.start()
    }

    func pushToOutdatedTravel(travel: Travel) {
        let outdatedTravelCoordinator = OutdatedTravelCoordinator(
            navigationController: self.navigationController, travel: travel
        )
        self.childCoordinators.append(outdatedTravelCoordinator)
        outdatedTravelCoordinator.start()
    }
}
