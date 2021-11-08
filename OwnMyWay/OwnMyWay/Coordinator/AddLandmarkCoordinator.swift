//
//  AddLandmarkCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class AddLandmarkCoordinator: Coordinator, AddLandmarkCoordinatingDelegate {

    var childCoordinators: [Coordinator] = []
    var travel: Travel
    var navigationController: UINavigationController

    init(navigationController: UINavigationController, travel: Travel) {
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let addLandmarkVM = AddLandmarkViewModel(travel: self.travel, coordinator: self)
        let addLandmarkVC = AddLandmarkViewController.instantiate(storyboardName: "AddLandmark")
        addLandmarkVC.bind(viewModel: addLandmarkVM)
        let landmarkCartCoordinator = LandmarkCartCoordinator(
            navigationController: self.navigationController,
            travel: self.travel
        )
        let cartVC = landmarkCartCoordinator.pass()
        self.childCoordinators.append(landmarkCartCoordinator)
        addLandmarkVC.bind { cartView in
            addLandmarkVC.addChild(cartVC)
            cartView.addSubview(cartVC.view)
            cartVC.view.translatesAutoresizingMaskIntoConstraints = false
            cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
            cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
            cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
            cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
        }
        navigationController.pushViewController(addLandmarkVC, animated: true)
    }

    func pushToComplete(travel: Travel) {
        print("🤷‍♂️🤷‍♂️🤷‍♂️🤷‍♂️🤷‍♂️")
        // push to complete
    }
}
