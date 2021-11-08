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
        let repository = DefaultLandmarkDTORepository()
        let usecase = DefaultSearchLandmarkUsecase(landmarkDTORepository: repository)
        let viewModel = SearchLandmarkViewModel(searchLandmarkUsecase: usecase, coordinator: self)
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
        guard let addVC = navigationController.viewControllers.last as? AddLandmarkViewController,
              let cartVC = addVC.children.first as? LandmarkCartViewController
        else { return }
        self.navigationController.viewControllers.last?.dismiss(animated: true) {
            cartVC.viewModel?.didAddLandmark(of: landmark)
        }
    }

}
