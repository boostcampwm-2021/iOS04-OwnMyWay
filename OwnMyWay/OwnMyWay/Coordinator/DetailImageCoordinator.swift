//
//  DetailImageCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import UIKit

final class DetailImageCoordinator: Coordinator, DetailImageCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    var imageIDs: [String]
    var selectedIndex: Int

    init(navigationController: UINavigationController, images: [String], index: Int) {
        self.navigationController = navigationController
        self.childCoordinators = []
        self.imageIDs = images
        self.selectedIndex = index
    }

    func start() {
        let imageVM = DefaultDetailImageViewModel(
            coordinatingDelegate: self,
            images: self.imageIDs,
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
        self.navigationController.viewControllers.last?.dismiss(animated: true)
    }

}
