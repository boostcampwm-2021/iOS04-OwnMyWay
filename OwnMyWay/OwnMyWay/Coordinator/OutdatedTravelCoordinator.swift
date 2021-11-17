//
//  OutdatedTravelCoordinator.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OutdatedTravelCoordinator: Coordinator, OngoingCoordinatingDelegate {
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
        let usecase = DefaultOngoingTravelUsecase(repository: repository)
        let outdatedVM = DefaultOngoingTravelViewModel(
            travel: self.travel, usecase: usecase, coordinatingDelegate: self
        )
        let outdatedVC = OutdatedTravelViewController.instantiate(storyboardName: "OutdatedTravel")
        outdatedVC.bind(viewModel: outdatedVM)
        self.navigationController.pushViewController(outdatedVC, animated: true)
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
    
    func pushToAddRecord(record: Record?) {
        <#code#>
    }
    
    func pushToEditTravel() {
        <#code#>
    }
    
    func moveToOutdated(travel: Travel) {
        <#code#>
    }
    
    func pushToDetailRecord(record: Record, travel: Travel) {
        <#code#>
    }
    
}
