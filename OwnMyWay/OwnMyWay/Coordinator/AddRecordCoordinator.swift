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
        self.navigationController.pushViewController(addRecordVC, animated: true)
    }

    func dismissToParent(with record: Record) {
        // TODO: Ongoing Fetch 또는 Record를 append 하는 방식 중 택1
    }
}
