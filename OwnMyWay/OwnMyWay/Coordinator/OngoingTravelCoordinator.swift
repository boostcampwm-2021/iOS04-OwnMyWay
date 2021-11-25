//
//  OngoingCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

final class OngoingTravelCoordinator: Coordinator, StartedCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        let repository = CoreDataTravelRepository(contextFetcher: appDelegate)
        let usecase = DefaultStartedTravelUsecase(repository: repository)
        let ongoingVM = DefaultStartedTravelViewModel(
            travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let ongoingVC = OngoingTravelViewController.instantiate(storyboardName: "OngoingTravel")
        ongoingVC.bind(viewModel: ongoingVM)
        self.navigationController.pushViewController(ongoingVC, animated: true)
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

    func pushToAddRecord(record: Record?) {
        let addRecordCoordinator = AddRecordCoordinator(
            navigationController: self.navigationController, record: record, isEditingMode: false
        )
        self.childCoordinators.append(addRecordCoordinator)
        addRecordCoordinator.start()
    }

    func pushToEditTravel(travel: Travel) {
        let createTravelCoordinator = CreateTravelCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(createTravelCoordinator)
        createTravelCoordinator.start()
    }

    func pushToDetailRecord(record: Record, travel: Travel) {
        let detailRecordCoordinator = DetailRecordCoordinator(
            navigationController: self.navigationController, record: record, travel: travel
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
