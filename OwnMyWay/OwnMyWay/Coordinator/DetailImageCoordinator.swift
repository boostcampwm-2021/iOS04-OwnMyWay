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
    var selectedIndex: Int

    init(navigationController: UINavigationController, images: [URL], index: Int) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.imageURLs = images
        self.selectedIndex = index
    }

    func start() {
        let imageVM = DefaultDetailImageViewModel(
            coordinatingDelegate: self,
            images: self.imageURLs,
            index: selectedIndex
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
