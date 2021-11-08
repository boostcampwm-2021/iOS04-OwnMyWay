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
        let usecase = DefaultHomeUsecase(travelRepository: repository)
        let homeVM = HomeViewModel(homeUsecase: usecase, coordinator: self)
        let homeVC = HomeViewController.instantiate(storyboardName: "Home")
        homeVC.bind(viewModel: homeVM)
        navigationController.pushViewController(homeVC, animated: false)
    }

    func pushToCreateTravel() {
        print("🤷‍♂️🤷‍♂️🤷‍♂️")
        // push to create travel
    }
}
