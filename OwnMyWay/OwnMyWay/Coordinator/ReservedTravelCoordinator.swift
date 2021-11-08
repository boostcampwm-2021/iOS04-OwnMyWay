//
//  ReservedTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import Foundation
import UIKit

class ReservedTravelCoordinator: Coordinator {
    var childCoordinators: [Coordinator]
    var travel: Travel
    var navigationController: UINavigationController

    init(navigationController: UINavigationController, travel: Travel) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.travel = travel
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultReservedTravelUsecase(travelRepository: repository)
        let reservedVM = ReservedTravelViewModel(reservedTravelUsecase: usecase, travel: travel)
        let reservedVC = ReservedTravelViewController.instantiate(storyboardName: "ReservedTravel")
        let landmarkCartCoordinator = LandmarkCartCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        let cartVC = landmarkCartCoordinator.pass()
        self.childCoordinators.append(landmarkCartCoordinator)
        reservedVC.bind(viewModel: reservedVM) { cartView in
            reservedVC.addChild(cartVC)
            cartView.addSubview(cartVC.view)
            cartVC.view.translatesAutoresizingMaskIntoConstraints = false
            cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
            cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
            cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
            cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
        }
        self.navigationController.pushViewController(reservedVC, animated: true)
    }

}
