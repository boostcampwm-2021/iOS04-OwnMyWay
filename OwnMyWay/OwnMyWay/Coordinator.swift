//
//  Coordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import UIKit

protocol AppCoordinator {
    func start()
}

protocol HomeCoordinator {
    func pushToCreateTravel()
    func pushToReservedTravel(travel: Travel)
}

protocol CreateTravelCoordinator {
    func pushToAddLandmark(travel: Travel)
}

protocol ReservedTravelCoordinator {
    func pushToNowTravel(travel: Travel)
}

class DefaultCoordinator: AppCoordinator, HomeCoordinator, CreateTravelCoordinator, ReservedTravelCoordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let homeVC = HomeViewController.instantiate(storyboardName: "Home")
        homeVC.coordinator = self
        navigationController.pushViewController(homeVC, animated: false)
    }

    func pushToCreateTravel() {
        let createTravelVC = CreateTravelViewController.instantiate(storyboardName: "CreateTravel")
        createTravelVC.coordinator = self
        navigationController.pushViewController(createTravelVC, animated: true)
    }

    func pushToReservedTravel(travel: Travel) {
        let reservedTravelVC = ReservedTravelViewController.instantiate(
            storyboardName: "ReservedTravel"
        )
        let cartVC = LandmarkCartViewController.instantiate(storyboardName: "LandmarkCart")

        let reservedTravelUsecase = DefaultReservedTravelUsecase(
            travelRepository: CoreDataTravelRepository()
        )
        let reserverTravleViewModel = ReservedTravelViewModel(
            reservedTravelUsecase: reservedTravelUsecase,
            travel: travel
        )

        reservedTravelVC.bind(viewModel: reserverTravleViewModel) { cartView in
            reservedTravelVC.addChild(cartVC)
            cartView.addSubview(cartVC.view)
            cartVC.view.translatesAutoresizingMaskIntoConstraints = false
            cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
            cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
            cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
            cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
        }

        let landmarkCartUsecase = DefaultLandmarkCartUsecase(
            travelRepository: CoreDataTravelRepository()
        )
        let landmarkViewModel = LandmarkCartViewModel(
            landmarkCartUsecase: landmarkCartUsecase,
            travel: travel
        )
        cartVC.bind(viewModel: landmarkViewModel)

        navigationController.pushViewController(reservedTravelVC, animated: true)
    }

    func pushToAddLandmark(travel: Travel) {
        let addLandmarkVC = AddLandmarkViewController.instantiate(storyboardName: "AddLandmark")
        let cartVC = LandmarkCartViewController.instantiate(storyboardName: "LandmarkCart")

        addLandmarkVC.bind { cartView in
            addLandmarkVC.addChild(cartVC)
            cartView.addSubview(cartVC.view)
            cartVC.view.translatesAutoresizingMaskIntoConstraints = false
            cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
            cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
            cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
            cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
        }

        let usecase = DefaultLandmarkCartUsecase(travelRepository: CoreDataTravelRepository())
        let viewModel = LandmarkCartViewModel(landmarkCartUsecase: usecase, travel: travel)
        cartVC.bind(viewModel: viewModel)

        navigationController.pushViewController(addLandmarkVC, animated: true)
    }

    func pushToNowTravel(travel: Travel) {
        // 구현 요망
    }
}
