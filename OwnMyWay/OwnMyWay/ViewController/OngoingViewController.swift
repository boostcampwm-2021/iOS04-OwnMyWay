//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OngoingViewController: UIViewController, Instantiable {
    @IBOutlet private weak var finishButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: OngoingViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.finishButtonHeightConstraint.constant = 60 + bottomPadding
    }

    func bind(viewModel: OngoingViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func didTouchAddRecordButton(_ sender: UIButton) {
        self.viewModel?.didTouchAddRecordButton()
    }

    @IBAction func didTouchFinishButton(_ sender: UIButton) {
        self.viewModel?.didTouchFinishButton()
    }

}
