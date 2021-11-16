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
    private var record: Record?

    init(navigationController: UINavigationController, record: Record?) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.record = record
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultAddRecordUsecase(
            repository: repository,
            imageFileManager: ImageFileManager(fileManager: FileManager.default)
        )
        let addRecordVM = DefaultAddRecordViewModel(
            record: self.record, usecase: usecase, coordinatingDelegate: self
        )
        let addRecordVC = AddRecordViewController.instantiate(storyboardName: "AddRecord")
        addRecordVC.bind(viewModel: addRecordVM)
        self.navigationController.pushViewController(addRecordVC, animated: true)
    }

    func popToParent(with record: Record) {
        self.navigationController.popViewController(animated: true)
        guard let upperVC = self.navigationController.viewControllers.last
                as? RecordUpdatable & UIViewController else { return }
        upperVC.didUpdateRecord(record: record)
    }
}
