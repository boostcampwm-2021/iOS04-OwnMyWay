//
//  OutdatedTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

final class OutdatedTravelCoordinator: Coordinator, StartedTravelCoordinatingDelegate {

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
        let outdatedVM = DefaultStartedTravelViewModel(
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

    func pushToAddRecord(record: Record?) {
        let addRecordCoordinator = AddRecordCoordinator(
            navigationController: self.navigationController, record: record, isEditingMode: false
        )
        self.childCoordinators.append(addRecordCoordinator)
        addRecordCoordinator.start()
    }

    func pushToEditTravel(travel: Travel) {
        let createTravelCoordinator = EnterTitleCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(createTravelCoordinator)
        createTravelCoordinator.start()
    }

    func moveToOutdated(travel: Travel) { return }

    func pushToDetailRecord(record: Record, travel: Travel) {
        let detailRecordCoordinator = DetailRecordCoordinator(
            navigationController: self.navigationController, record: record, travel: travel
        )
        self.childCoordinators.append(detailRecordCoordinator)
        detailRecordCoordinator.start()
    }

}
