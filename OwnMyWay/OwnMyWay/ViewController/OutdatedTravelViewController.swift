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

    private func configureNavigation() {
        self.navigationItem.title = viewModel?.travel.title

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonAction)
        )
    }

    func bind(viewModel: OutdatedTravelViewModel) {
        self.viewModel = viewModel
    }

    @objc private func backButtonAction() {
        self.viewModel?.didTouchBackButton()
    }
}
