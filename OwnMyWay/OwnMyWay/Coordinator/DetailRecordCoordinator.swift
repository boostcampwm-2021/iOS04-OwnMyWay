//
//  DetailRecordCoordinator.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

class DetailRecordCoordinator: Coordinator, DetailRecordCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    var record: Record

    init(navigationController: UINavigationController, record: Record) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.record = record
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultDetailRecordUsecase(repository: repository)
        let detailRecordVM = DefaultDetailRecordViewModel(
            record: self.record, usecase: usecase, coordinatingDelegate: self
        )
        let detailRecordVC = DetailRecordViewController.instantiate(storyboardName: "DetailRecord")
        detailRecordVC.bind(viewModel: detailRecordVM)
        self.navigationController.pushViewController(detailRecordVC, animated: true)
    }

    func pushToAddRecord(record: Record) {
        let addRecordCoordinator = AddRecordCoordinator(
            navigationController: self.navigationController, record: record
        )
        self.childCoordinators.append(addRecordCoordinator)
        addRecordCoordinator.start()
    }

}
