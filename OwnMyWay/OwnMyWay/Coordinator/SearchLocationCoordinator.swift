//
//  SearchLocationCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/18.
//

import UIKit

class SearchLocationCoordinator: Coordinator, SearchLocationCoordinatingDelegate {
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.childCoordinators = []
        self.navigationController = navigationController
    }

    func start() {
        let searchLocationVM = DefaultSearchLocationViewModel(coordinatingDelegate: self)
        let searchLocationVC = SearchLocationViewController
            .instantiate(storyboardName: "SearchLocation")
        searchLocationVC.bind(viewModel: searchLocationVM)
        self.navigationController.children.last?.present(searchLocationVC, animated: true)
    }

    func dismissToAddRecord(title: String?, latitude: Double, longitude: Double) {
        guard let parent = self.navigationController.children.last as? AddRecordViewController
        else { return }
        parent.dismiss(animated: true) {
            parent.update(recordPlace: title, latitude: latitude, longitude: longitude)
        }
    }
}
