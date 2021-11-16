//
//  OutdatedTravelViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OutdatedTravelViewController: UIViewController, Instantiable {

    private var viewModel: OutdatedTravelViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    private func configureNavigation() {
        self.navigationItem.title = viewModel?.travel.title
    }

    func bind(viewModel: OutdatedTravelViewModel) {
        self.viewModel = viewModel
    }

}
