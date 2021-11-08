//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController, Instantiable {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cartView: UIView!
    private var bindContainerVC: ((UIView) -> Void)?
    private var viewModel: AddLandmarkViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindContainerVC?(self.cartView)
    }

    func bind(viewModel: AddLandmarkViewModelType) {
        self.viewModel = viewModel
    }

    func bind(closure: @escaping (UIView) -> Void) {
        self.bindContainerVC = closure
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mapViewHeight: CGFloat = UIScreen.main.bounds.width
        let collectionViewHeight: CGFloat = 220
        contentView.heightAnchor
            .constraint(equalToConstant: mapViewHeight + collectionViewHeight)
            .isActive = true
        view.layoutIfNeeded()
    }

    @IBAction func nextButtonDidTouched(_ sender: Any) {
        self.viewModel?.nextButtonTouched()
    }
}
