//
//  LandmarkCartCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class LandmarkCartCoordinator: Coordinator, LandmarkCartCoordinatingDelegate {
    
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        fatalError("잘못된 접근입니다.")
    }

    func pass(from superVC: SuperVC) -> LandmarkCartViewController {
        let cartVC = LandmarkCartViewController.instantiate(storyboardName: "LandmarkCart")
        let viewModel = DefaultLandmarkCartViewModel(
            coordinatingDelegate: self,
            travel: travel,
            superVC: superVC
        )
        cartVC.bind(viewModel: viewModel)
        return cartVC
    }

    func presentSearchLandmarkModally() {
        let searchLandmarkCoordinator = SearchLandmarkCoordinator(
            navigationController: self.navigationController
        )
        self.childCoordinators.append(searchLandmarkCoordinator)
        searchLandmarkCoordinator.start()
    }

}
