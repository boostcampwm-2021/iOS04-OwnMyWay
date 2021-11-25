//
//  AddRecordCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

final class AddRecordCoordinator: Coordinator, AddRecordCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var record: Record?
    private var isEditingMode: Bool

    init(navigationController: UINavigationController, record: Record?, isEditingMode: Bool) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.record = record
        self.isEditingMode = isEditingMode
    }

    func start() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        let repository = CoreDataTravelRepository(contextFetcher: appDelegate)
        let usecase = DefaultAddRecordUsecase(
            repository: repository,
            imageFileManager: ImageFileManager.shared
        )
        let addRecordVM = DefaultAddRecordViewModel(
            record: self.record,
            usecase: usecase,
            coordinatingDelegate: self,
            isEditingMode: self.isEditingMode
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

    func presentToSearchLocation() {
        let searchLocationCoordinator = SearchLocationCoordinator(
            navigationController: self.navigationController
        )
        self.childCoordinators.append(searchLocationCoordinator)
        searchLocationCoordinator.start()
    }

}
