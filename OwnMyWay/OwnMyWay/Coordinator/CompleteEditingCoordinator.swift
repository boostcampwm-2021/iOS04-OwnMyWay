//
//  CompleteEditingCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import UIKit

class CompleteEditingCoordinator: Coordinator, CompleteEditingCoordinatingDelegate {

    var childCoordinators: [Coordinator]
    var navigationController: UINavigationController
    private var travel: Travel

    init(navigationController: UINavigationController, travel: Travel) {
        self.childCoordinators = []
        self.navigationController = navigationController
        self.travel = travel
    }

    func start() {
        let repository = CoreDataTravelRepository()
        let usecase = DefaultCompleteEditingUsecase(repository: repository)
        let completeEditingVM = DefaultCompleteEditingViewModel(
            usecase: usecase, coordinatingDelegate: self, travel: self.travel
        )
        let completeEditingVC = CompleteEditingViewController.instantiate(
            storyboardName: "CompleteEditing"
        )
        completeEditingVC.bind(viewModel: completeEditingVM)
        self.navigationController.pushViewController(completeEditingVC, animated: true)
    }

    func popToTravelViewController(travel: Travel) {
        let viewControllers = self.navigationController.viewControllers
        guard viewControllers.count >= 4
        else { return }
        let travelViewController = viewControllers[viewControllers.count - 4]
        self.navigationController.popToViewController(travelViewController, animated: true)
        if let travelVC = self.navigationController.viewControllers.last as? TravelUpdatable {
            travelVC.didUpdateTravel(to: travel)
        }
    }

}
