//
//  OutdatedTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OutdatedTravelCoordinator: Coordinator, OutdatedTravelCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultOutdatedTravelUsecase(repository: repository)
        let outdatedVM = DefaultOutdatedTravelViewModel(
            travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let outdatedVC = OutdatedTravelViewController.instantiate(storyboardName: "OutdatedTravel")
        outdatedVC.bind(viewModel: outdatedVM)
        self.navigationController.pushViewController(outdatedVC, animated: true)
    }

    func popToHome() {
        guard let homeVC = self
                .navigationController
                .viewControllers
                .first as? TravelFetchable
        else { return }
        homeVC.fetchTravel()
        self.navigationController.popToRootViewController(animated: true)
    }
}
