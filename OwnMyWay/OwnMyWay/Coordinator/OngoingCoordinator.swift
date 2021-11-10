//
//  OngoingCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OngoingCoordinator: Coordinator, OngoingCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultOngoingUsecase(repository: repository)
        let ongoingVM = DefaultOngoingViewModel(usecase: usecase, coordinatingDelegate: self)
        let ongoingVC = OngoingViewController.instantiate(storyboardName: "Ongoing")
        ongoingVC.bind(viewModel: ongoingVM)
        navigationController.pushViewController(ongoingVC, animated: true)
    }
}
