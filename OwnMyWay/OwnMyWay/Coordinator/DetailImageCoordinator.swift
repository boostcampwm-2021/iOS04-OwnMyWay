//
//  DetailImageCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import UIKit

class DetailImageCoordinator: Coordinator, DetailImageCoordinatingDelegate {
    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    var imageURLs: [URL]

    init(navigationController: UINavigationController, images: [URL]) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.imageURLs = images
    }

    func start() {
        let imageVM = DefaultDetailImageViewModel(
            images: self.imageURLs, coordinatingDelegate: self
        )
        let imageVC = DetailImageViewController.instantiate(storyboardName: "DetailImage")
        imageVC.bind(viewModel: imageVM)
        imageVC.modalPresentationStyle = .fullScreen
        imageVC.modalTransitionStyle = .coverVertical
        self.navigationController.viewControllers.last?.present(
            imageVC, animated: true
        )
    }

    func dismissToImageDetail() {
        navigationController.viewControllers.last?.dismiss(animated: true)
    }

}
