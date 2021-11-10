//
//  AddRecordCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class AddRecordCoordinator: Coordinator, AddRecordCoordinatingDelegate {

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
        let usecase = DefaultAddRecordUsecase(repository: repository)
        let addRecordVM = DefaultAddRecordViewModel(
            travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let addRecordVC = AddRecordViewController.instantiate(storyboardName: "AddRecord")
        addRecordVC.bind(viewModel: addRecordVM)
        navigationController.pushViewController(addRecordVC, animated: true)
    }
}
