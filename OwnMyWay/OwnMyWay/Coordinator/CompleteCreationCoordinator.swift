//
//  CompleteCreationCoordinator.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import UIKit

class CompleteCreationCoordinator: Coordinator, CompleteCreationCoordinatingDelegate {

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
        let usecase = DefaultCompleteCreationUsecase(repository: repository)
        let completeCreationVM = DefaultCompleteCreationViewModel(
            usecase: usecase, coordinatingDelegate: self, travel: self.travel
        )
        let completeCreationVC = CompleteCreationViewController.instantiate(
            storyboardName: "CompleteCreation"
        )
        completeCreationVC.bind(viewModel: completeCreationVM)
        self.navigationController.pushViewController(completeCreationVC, animated: true)
    }

    func popToHome() {
        guard let homeVC = self
                .navigationController
                .viewControllers
                .first as? TravelFetchable
        else { return }
        homeVC.fetchTravel()
        self.navigationController.popToRootViewController(animated: true)
    }

}
