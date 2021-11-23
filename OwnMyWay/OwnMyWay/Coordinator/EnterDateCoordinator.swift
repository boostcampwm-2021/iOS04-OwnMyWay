//
//  EnterDate.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/23.
//

import UIKit

class EnterDateCoordinator: Coordinator, EnterDateCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var travel: Travel
    private var isEditingMode: Bool

    init(navigationController: UINavigationController, travel: Travel, isEditingMode: Bool) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
        self.isEditingMode = isEditingMode
    }

    func start() {
        let usecase = DefaultEnterDateUsecase()
        let enterDateVM = DefaultEnterDateViewModel(
            usecase: usecase,
            coordinatingDelegate: self,
            travel: self.travel,
            isEditingMode: self.isEditingMode
        )
        let enterDateVC = EnterDateViewController.instantiate(storyboardName: "EnterDate")
        enterDateVC.bind(viewModel: enterDateVM)
        self.navigationController.pushViewController(enterDateVC, animated: true)
    }

    func pushToAddLandmark(travel: Travel, isEditingMode: Bool) {
        let addLandmarkCoordinator = AddLandmarkCoordinator(
            navigationController: self.navigationController,
            travel: travel,
            isEditingMode: isEditingMode
        )
        self.childCoordinators.append(addLandmarkCoordinator)
        addLandmarkCoordinator.start()
    }

    func popToCreateTravel(travel: Travel) {
        guard let createTravelVC = self.navigationController.children.last
                as? CreateTravelViewController else { return }

        createTravelVC.travelDidChanged(to: travel)
    }
}
