//
//  SearchLandmarkCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

class SearchLandmarkCoordinator: Coordinator, SearchLandmarkCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.childCoordinators = []
    }

    func start() {
        let repository = LocalJSONLandmarkRepository()
        let usecase = DefaultSearchLandmarkUsecase(repository: repository)
        let viewModel = DefaultSearchLandmarkViewModel(
            usecase: usecase,
            coordinatingDelegate: self
        )
        let searchLandmarkVC = SearchLandmarkViewController.instantiate(
            storyboardName: "SearchLandmark"
        )
        searchLandmarkVC.bind(viewModel: viewModel)
        navigationController.viewControllers.last?.present(
            searchLandmarkVC,
            animated: true
        )
    }

    func dismissToAddLandmark(landmark: Landmark) {
        guard let upperVC = navigationController
                .viewControllers
                .last as? TravelUpdatable & UIViewController,
              let cartVC = upperVC.children.first as? LandmarkCartViewController
        else { return }

        upperVC.dismiss(animated: true) {
            guard let viewModel = cartVC.viewModel else { return }
            viewModel.didAddLandmark(of: landmark)
            upperVC.updateTravel(with: viewModel.travel)
        }
    }

}
