//
//  CompleteCreationViewController.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import UIKit

class CompleteCreationViewController: UIViewController, Instantiable {

    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: CompleteCreationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationController()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: CompleteCreationViewModel) {
        self.viewModel = viewModel
    }

    private func configureNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "새로운 여행"
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    @IBAction func didTouchCompleteButton(_ sender: UIButton) {
        self.viewModel?.didTouchCompleteButton()
    }

}
