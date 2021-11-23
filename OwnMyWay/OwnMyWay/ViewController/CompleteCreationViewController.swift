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

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: CompleteCreationViewModel) {
        self.viewModel = viewModel
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    @IBAction func didTouchCompleteButton(_ sender: UIButton) {
        switch self.viewModel?.didTouchCompleteButton() {
        case .success:
            break
        case .failure(let error):
            print(error)
        case .none:
            print("App 터졌다구~")
        }
    }

}
