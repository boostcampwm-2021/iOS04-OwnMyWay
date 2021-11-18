//
//  AddLandmarkCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class AddLandmarkCoordinator: Coordinator, AddLandmarkCoordinatingDelegate {

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
        let addLandmarkVM = DefaultAddLandmarkViewModel(
            travel: self.travel, coordinatingDelegate: self, isEditingMode: self.isEditingMode
        )
        let addLandmarkVC = AddLandmarkViewController.instantiate(storyboardName: "AddLandmark")
        let landmarkCartCoordinator = LandmarkCartCoordinator(
            navigationController: self.navigationController,
            travel: self.travel
        )
        let cartVC = landmarkCartCoordinator.pass()
        self.childCoordinators.append(landmarkCartCoordinator)
        addLandmarkVC.bind(viewModel: addLandmarkVM) { cartView in
            addLandmarkVC.addChild(cartVC)
            cartView.addSubview(cartVC.view)
            cartVC.view.translatesAutoresizingMaskIntoConstraints = false
            cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
            cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
            cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
            cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
            cartVC.didMove(toParent: addLandmarkVC)
        }
        self.navigationController.pushViewController(addLandmarkVC, animated: true)
    }

    func pushToCompleteCreation(travel: Travel) {
        let completeCreationCoordinator = CompleteCreationCoordinator(
            navigationController: self.navigationController, travel: travel
        )
        self.childCoordinators.append(completeCreationCoordinator)
        completeCreationCoordinator.start()
    }

    func pushToCompleteEditing(travel: Travel) {
        let completeEditingCoordinator = CompleteEditingCoordinator(
            navigationController: self.navigationController, travel: travel
        )
        self.childCoordinators.append(completeEditingCoordinator)
        completeEditingCoordinator.start()
    }

    func popToCreateTravel(travel: Travel) {
        guard let createTravelVC = self.navigationController.children.last
                as? CreateTravelViewController else { return }

        createTravelVC.travelDidChanged(to: travel)
    }
}
