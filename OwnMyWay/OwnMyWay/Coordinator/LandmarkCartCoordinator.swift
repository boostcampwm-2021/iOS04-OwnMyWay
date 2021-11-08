//
//  LandmarkCartCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class LandmarkCartCoordinator: Coordinator, LandmarkCartCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var travel: Travel
    var navigationController: UINavigationController

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        fatalError("잘못된 접근입니다.")
    }

    func pass() -> LandmarkCartViewController {
        let cartVC = LandmarkCartViewController.instantiate(storyboardName: "LandmarkCart")
        let usecase = DefaultLandmarkCartUsecase(travelRepository: CoreDataTravelRepository())
        let viewModel = LandmarkCartViewModel(
            landmarkCartUsecase: usecase,
            coordinator: self,
            travel: travel
        )
        cartVC.bind(viewModel: viewModel)
        return cartVC
    }

    func presentSearchLandmarkModally() {
        print("Modal")
    }

}
