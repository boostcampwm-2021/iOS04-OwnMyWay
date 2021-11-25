//
//  DetailRecordCoordinator.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

final class DetailRecordCoordinator: Coordinator, DetailRecordCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var record: Record
    private var travel: Travel

    init(navigationController: UINavigationController, record: Record, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.record = record
        self.travel = travel
    }

    func start() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        let repository = CoreDataTravelRepository(contextFetcher: appDelegate)
        let usecase = DefaultDetailRecordUsecase(repository: repository)
        let detailRecordVM = DefaultDetailRecordViewModel(
            record: self.record, travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let detailRecordVC = DetailRecordViewController.instantiate(storyboardName: "DetailRecord")
        detailRecordVC.bind(viewModel: detailRecordVM)
        self.navigationController.pushViewController(detailRecordVC, animated: true)
    }

    func popToParent(with travel: Travel, isPopable: Bool) {
        if isPopable {
            self.navigationController.popViewController(animated: true)
        }
        guard let parentVC = navigationController
                .viewControllers
                .last as? TravelUpdatable & UIViewController
        else { return }
        parentVC.didUpdateTravel(to: travel)
    }

    func pushToAddRecord(record: Record) {
        let addRecordCoordinator = AddRecordCoordinator(
            navigationController: self.navigationController, record: record, isEditingMode: true
        )
        self.childCoordinators.append(addRecordCoordinator)
        addRecordCoordinator.start()
    }

    func presentDetailImage(images: [String], index: Int) {
        let detailImageCoordinator = DetailImageCoordinator(
            navigationController: self.navigationController, images: images, index: index
        )
        self.childCoordinators.append(detailImageCoordinator)
        detailImageCoordinator.start()
    }

}
