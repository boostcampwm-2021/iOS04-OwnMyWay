//
//  ReservedTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/04.
//

import UIKit

class ReservedTravelViewController: UIViewController, Instantiable, TravelUpdatable {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var cartView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var travelTypeLabel: UILabel!
    @IBOutlet weak var startButton: NextButton!
    private var bindContainerVC: ((UIView) -> Void)?
    private var viewModel: ReservedTravelViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDescription()
        self.configureStartButton()
        self.bindContainerVC?(self.cartView)
    }

    func bind(viewModel: ReservedTravelViewModelType, closure: @escaping (UIView) -> Void) {
        self.viewModel = viewModel
        self.bindContainerVC = closure
    }

    func updateTravel(with travel: Travel) {
        self.viewModel?.travelDidUpdate(travel: travel)
    }

    private func configureDescription() {
        guard let viewModel = self.viewModel else {
            return
        }
        self.navigationItem.title = viewModel.travel.title
        if let startDate = viewModel.travel.startDate, let endDate = viewModel.travel.endDate {
            self.dateLabel.text = "\(startDate.format(endDate: endDate))"
        }
        self.travelTypeLabel.text = "예정된 여행"

        let removeButton = UIBarButtonItem(
            title: "삭제",
            style: .plain,
            target: self,
            action: #selector(didTouchRemoveButton(_:))
        )

        self.navigationItem.rightBarButtonItem = removeButton
    }

    private func configureStartButton() {
        guard let viewModel = self.viewModel else { return }
        self.startButton.setAvailability(to: viewModel.isPossibleStart)
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

    @IBAction func didTouchStartButton(_ sender: Any) {
        guard let viewModel = self.viewModel else {
            return
        }
        //  FIXME
        // 카트 뷰모델 거 직접 줘야하는데.. 고민중
        // 넘겨 받은 얘 진행중인 여행이 id로 다시 불러오는거 추천
        //self.coordinator?.pushToNowTravel(travel: viewModel.travel)
    }

    @objc func didTouchRemoveButton(_ sender: Any) {
        self.presentAlert()
    }

    private func presentAlert() {
        let alert = UIAlertController(title: "여행 삭제",
                                      message: "정말로 삭제하실건가요?\n 삭제된 여행은 되돌릴 수 없어요",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.viewModel?.didDeleteTravel()
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }
}
