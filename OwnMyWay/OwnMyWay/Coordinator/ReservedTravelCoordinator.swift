//
//  ReservedTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class ReservedTravelCoordinator: Coordinator, ReservedTravelCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultReservedTravelUsecase(repository: repository)
        let reservedVM = DefaultReservedTravelViewModel(
            usecase: usecase,
            travel: travel,
            coordinatingDelegate: self
        )
        let reservedVC = ReservedTravelViewController.instantiate(storyboardName: "ReservedTravel")
        let landmarkCartCoordinator = LandmarkCartCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        let cartVC = landmarkCartCoordinator.pass(from: .reserved)
        self.childCoordinators.append(landmarkCartCoordinator)
        reservedVC.bind(viewModel: reservedVM) { cartView in
            reservedVC.addChild(cartVC)
            cartView.addSubview(cartVC.view)
            cartVC.view.translatesAutoresizingMaskIntoConstraints = false
            cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
            cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
            cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
            cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
            cartVC.didMove(toParent: reservedVC)
        }
        self.navigationController.pushViewController(reservedVC, animated: true)
    }

    func popToHome() {
        guard let homeVC = self
                .navigationController
                .viewControllers
                .first as? TravelFetchable
        else { return }
        homeVC.fetchTravel()
        self.navigationController.popToRootViewController(animated: true)
    }

    func moveToOngoing(travel: Travel) {
        self.navigationController.popToRootViewController(animated: true)
        let ongoingCoordinator = OngoingTravelCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(ongoingCoordinator)
        ongoingCoordinator.start()
    }

    func pushToEditTravel(travel: Travel) {
        let createTravelCoordinator = CreateTravelCoordinator(
            navigationController: self.navigationController,
            travel: travel
        )
        self.childCoordinators.append(createTravelCoordinator)
        createTravelCoordinator.start()
    }

}
