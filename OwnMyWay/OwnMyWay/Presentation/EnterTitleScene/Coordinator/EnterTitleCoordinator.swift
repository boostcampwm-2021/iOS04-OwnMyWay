//
//  CreateTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import UIKit

protocol EnterTitleCoordinatingDelegate: AnyObject {
    func pushToEnterDate(travel: Travel, isEditingMode: Bool)
}

final class EnterTitleCoordinator: Coordinator, EnterTitleCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var travel: Travel?

    init(navigationController: UINavigationController, travel: Travel?) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let usecase = DefaultEnterTitleUsecase()
        let enterTitleVM = DefaultEnterTitleViewModel(
            usecase: usecase,
            coordinatingDelegate: self,
            travel: self.travel
        )
        let enterTitleVC = EnterTitleViewController.instantiate(storyboardName: "EnterTitle")
        enterTitleVC.bind(viewModel: enterTitleVM)
        self.navigationController.pushViewController(enterTitleVC, animated: true)
    }

    func pushToEnterDate(travel: Travel, isEditingMode: Bool) {
        let enterDateCoordinator = EnterDateCoordinator(
            navigationController: self.navigationController,
            travel: travel,
            isEditingMode: isEditingMode
        )
        self.childCoordinators.append(enterDateCoordinator)
        enterDateCoordinator.start()
    }

}
