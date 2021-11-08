//
//  CreateTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class CreateTravelCoordinator: Coordinator, CreateTravelCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultCreateTravelUsecase(travelRepository: repository)
        let createTravelVM = CreateTravelViewModel(createTravelUsecase: usecase, coordinator: self)
        let createTravelVC = CreateTravelViewController.instantiate(storyboardName: "CreateTravel")
        createTravelVC.bind(viewModel: createTravelVM)
        navigationController.pushViewController(createTravelVC, animated: true)
    }

    func pushToAddLandmark(travel: Travel) {
        #if DEBUG
            print("push to add landmark")
        #endif
    }
}
