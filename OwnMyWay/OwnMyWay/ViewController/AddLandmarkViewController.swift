//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController,
                                 Instantiable,
                                 TravelUpdatable,
                                 LandmarkDeletable {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cartView: UIView!
    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var bindContainerVC: ((UIView) -> Void)?
    private var viewModel: AddLandmarkViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel?.bind { error in
            print(error)
        }
        self.bindContainerVC?(self.cartView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.bindContainerVC = nil
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: AddLandmarkViewModel, closure: @escaping (UIView) -> Void) {
        self.viewModel = viewModel
        self.bindContainerVC = closure
    }

    func didUpdateTravel(to travel: Travel) {
        self.viewModel?.didUpdateTravel(to: travel)
    }

    func didDeleteLandmark(at landmark: Landmark) {
        self.viewModel?.didDeleteLandmark(at: landmark)
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    @IBAction func didTouchNextButton(_ sender: Any) {
        self.viewModel?.didTouchNextButton()
    }

}
