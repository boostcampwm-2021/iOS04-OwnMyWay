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

    // FIXME: travel 추가하기
    func pushToAddRecord() {}

    // FIXME: travel 추가하기
    func pushToEditTravel() {}

    func pushToDetailRecord(record: Record) {
        let detailRecordCoordinator = DetailRecordCoordinator(
            navigationController: self.navigationController, record: record
        )
        self.childCoordinators.append(detailRecordCoordinator)
        detailRecordCoordinator.start()
    }
}
