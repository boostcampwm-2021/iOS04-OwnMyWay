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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }
        let repository = CoreDataTravelRepository(contextFetcher: appDelegate)
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
        let travelVC = viewControllers.first {
            $0 is TravelEditable
        }
        guard let travelVC = travelVC as? UIViewController & TravelEditable
        else { return }
        travelVC.didEditTravel(to: travel)
        self.navigationController.popToViewController(travelVC, animated: true)
    }

}
