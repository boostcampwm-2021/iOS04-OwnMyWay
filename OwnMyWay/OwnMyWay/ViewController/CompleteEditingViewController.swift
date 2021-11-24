//
//  CompleteEditingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import Combine
import UIKit

class CompleteEditingViewController: UIViewController, Instantiable {

    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: CompleteEditingViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCancellables()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationController()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: CompleteEditingViewModel) {
        self.viewModel = viewModel
    }

    private func configureCancellables() {
        self.viewModel?.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] optionalError in
                guard let error = optionalError else { return }
                ErrorManager.showAlert(with: error, to: self)
            }
            .store(in: &self.cancellables)
    }

    private func configureNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = "여행 편집하기"
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    @IBAction func didTouchCompleteButton(_ sender: UIButton) {
        self.viewModel?.didTouchCompleteButton()
    }

}
