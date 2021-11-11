//
//  OngoingCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OngoingTravelCoordinator: Coordinator, OngoingCoordinatingDelegate {

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
        let usecase = DefaultOngoingTravelUsecase(repository: repository)
        let ongoingVM = DefaultOngoingTravelViewModel(
            travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let ongoingVC = OngoingTravelViewController.instantiate(storyboardName: "OngoingTravel")
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

    func pushToDetailRecord(record: Record) {
        let detailRecordCoordinator = DetailRecordCoordinator(
            navigationController: self.navigationController, record: record
        )
        self.childCoordinators.append(detailRecordCoordinator)
        detailRecordCoordinator.start()
    }

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
