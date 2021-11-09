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
    var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let addLandmarkVM = DefaultAddLandmarkViewModel(travel: self.travel, coordinatingDelegate: self)
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
        }
        navigationController.pushViewController(addLandmarkVC, animated: true)
    }

    func pushToComplete(travel: Travel) {
        print(travel)
        // push to complete
    }

    func popToCreateTravel(travel: Travel) {
        guard let createTravelVC = self.navigationController.children.secondLast
                as? CreateTravelViewController else { return }

        createTravelVC.travelDidChanged(to: travel)
        self.navigationController.popViewController(animated: true)
    }
}

fileprivate extension Array {
    var secondLast: Element? {
        guard self.count >= 2 else { return nil }
        return self[self.count - 2]
    }
}
