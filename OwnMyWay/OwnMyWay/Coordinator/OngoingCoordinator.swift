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
    var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultOngoingUsecase(repository: repository)
        let ongoingVM = DefaultOngoingViewModel(
            travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let ongoingVC = OngoingViewController.instantiate(storyboardName: "Ongoing")
        ongoingVC.bind(viewModel: ongoingVM)
        navigationController.pushViewController(ongoingVC, animated: true)
    }

    func popToHome() {}

    func pushToAddRecord(travel: Travel) {
        let addRecordCoordinator = AddRecordCoordinator(
            navigationController: self.navigationController, travel: travel
        )
        self.childCoordinators.append(addRecordCoordinator)
        addRecordCoordinator.start()
    }

    // FIXME: travel 추가하기
    func pushToEditTravel() {}

    func moveToOutdated(travel: Travel) {
        self.navigationController.popToRootViewController(animated: true)
        let outdatedTravelCoordinator = OutdatedTravelCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(outdatedTravelCoordinator)
        outdatedTravelCoordinator.start()
    }
}
