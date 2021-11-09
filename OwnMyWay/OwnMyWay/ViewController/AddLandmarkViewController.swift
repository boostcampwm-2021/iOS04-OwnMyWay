//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController, Instantiable, TravelUpdatable {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cartView: UIView!
    private var bindContainerVC: ((UIView) -> Void)?
    private var viewModel: AddLandmarkViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindContainerVC?(self.cartView)
        self.configureNavigation()
    }

    private func configureNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonTouched)
        )
    }

    @objc private func backButtonTouched() {
        self.viewModel?.backButtonTouched()
    }

    func bind(viewModel: AddLandmarkViewModelType, closure: @escaping (UIView) -> Void) {
        self.viewModel = viewModel
        self.bindContainerVC = closure
    }

    func updateTravel(with travel: Travel) {
        self.viewModel?.travelDidUpdate(travel: travel)
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
