//
//  CreateTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import UIKit

final class EnterTitleViewController: UIViewController, Instantiable {

    @IBOutlet private weak var travelTitleField: UITextField!
    @IBOutlet private weak var nextButton: NextButton!
    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: EnterTitleViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCancellable()
        self.configureGestureRecognizer()
        self.travelTitleField.delegate = self
        self.configureLabels()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationController()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: EnterTitleViewModel) {
        self.viewModel = viewModel
    }

    func travelDidChanged(to travel: Travel) {
        self.viewModel?.travelDidChanged(to: travel)
    }

    private func configureNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = ""
        guard let isEditingMode = self.viewModel?.isEditingMode else { return }
        self.navigationItem.title = isEditingMode ? "여행 편집하기" : "새로운 여행"
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isValid in
                self?.nextButton.setAvailability(to: isValid ?? false)
            }
            .store(in: &cancellables)
    }

    private func configureLabels() {
        self.viewModel?.viewDidLoad { [weak self] title in
            if let title = title {
                self?.navigationItem.title = "여행 편집하기"
                self?.travelTitleField.text = title
            } else {
                self?.navigationItem.title = "새로운 여행"
            }
        }
    }

    private func configureGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didChangeTitle(text: sender.text)
    }

    @IBAction func didTouchNextButton(_ sender: UIButton) {
        self.viewModel?.didTouchNextButton()
    }

}

extension EnterTitleViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.travelTitleField.resignFirstResponder()
        return true
    }
}
