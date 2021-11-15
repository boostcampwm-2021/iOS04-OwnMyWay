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

    private var bindContainerVC: ((UIView) -> Void)?
    private var viewModel: AddLandmarkViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigation()
        self.bindContainerVC?(self.cartView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mapViewHeight: CGFloat = UIScreen.main.bounds.width
        let collectionViewHeight: CGFloat = 220
        self.contentView.heightAnchor
            .constraint(equalToConstant: mapViewHeight + collectionViewHeight)
            .isActive = true
        self.view.layoutIfNeeded()
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

    private func configureNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonAction)
        )
    }

    @objc private func backButtonAction() {
        self.viewModel?.didTouchBackButton()
    }

    @IBAction func didTouchNextButton(_ sender: Any) {
        self.viewModel?.didTouchNextButton()
    }

}
