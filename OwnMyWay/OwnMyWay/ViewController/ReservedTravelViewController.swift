//
//  ReservedTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import Combine
import UIKit

class ReservedTravelViewController: UIViewController,
                                    Instantiable,
                                    TravelUpdatable,
                                    LandmarkDeletable {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cartView: UIView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var travelTypeLabel: UILabel!
    @IBOutlet private weak var startButton: NextButton!
    @IBOutlet weak var startButtonHeightConstraint: NSLayoutConstraint!

    private var bindContainerVC: ((UIView) -> Void)?
    private var viewModel: ReservedTravelViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDescription()
        self.configureStartButton()
        self.configureCancellable()
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mapViewHeight: CGFloat = UIScreen.main.bounds.width
        let collectionViewHeight: CGFloat = 220
        contentView.heightAnchor
            .constraint(equalToConstant: mapViewHeight + collectionViewHeight)
            .isActive = true
        view.layoutIfNeeded()
    }

    func bind(viewModel: ReservedTravelViewModel, closure: @escaping (UIView) -> Void) {
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
        self.startButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureDescription() {
        self.travelTypeLabel.text = "예정된 여행"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(self.didTouchSettingButton)
        )
    }

    private func configureCancellable() {
        self.viewModel?.travelPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] travel in
                let title = travel.title
                self?.navigationItem.title = title

                if let startDate = travel.startDate,
                    let endDate = travel.endDate {
                    self?.dateLabel.text = "\(startDate.format(endDate: endDate))"
                }
            }
            .store(in: &cancellables)
    }

    @objc private func backButtonAction() {
        self.viewModel?.didTouchBackButton()
    }

    @objc func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.presentAlert()
        }
        let editAction = UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            self?.viewModel?.didTouchEditButton()
        }
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }

    private func configureStartButton() {
        guard let viewModel = self.viewModel
        else { return }
        self.startButton.setAvailability(to: viewModel.isPossibleStart)
    }

    private func presentAlert() {
        let alert = UIAlertController(
            title: "여행 삭제",
            message: "정말로 삭제하실건가요?\n 삭제된 여행은 되돌릴 수 없어요",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.viewModel?.didDeleteTravel()
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

    @IBAction func didTouchStartButton(_ sender: Any) {
        self.viewModel?.didTouchStartButton()
    }

}
