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

    func popToHome() {
        // FIXME: 구현 요망
        // travel CoreData 업데이트
        // pop 2~3번
        // pop후 새로운 화면에서 travel Fetch
    }

}
