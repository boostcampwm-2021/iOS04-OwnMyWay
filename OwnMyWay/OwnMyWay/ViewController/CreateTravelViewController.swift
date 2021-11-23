//
//  CreateTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import FSCalendar
import UIKit

class CreateTravelViewController: UIViewController, Instantiable {

    @IBOutlet private weak var travelTitleField: UITextField!
    @IBOutlet private weak var nextButton: NextButton!
    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: CreateTravelViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private var prevDate: Date?
    private var isSelectionComplete: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCancellable()
        self.configureGestureRecognizer()
        self.travelTitleField.delegate = self
        self.configureLabels()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: CreateTravelViewModel) {
        self.viewModel = viewModel
    }

    func travelDidChanged(to travel: Travel) {
        self.viewModel?.travelDidChanged(to: travel)
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.nextButton.setAvailability(to: isValid ?? false)
            }
            .store(in: &cancellables)
    }

    private func configureLabels() {
        self.viewModel?.viewDidLoad { [weak self] title in
            guard let title = title
            else { return }
            self?.isSelectionComplete = true
            self?.navigationItem.title = "기록 편집하기"
            self?.travelTitleField.text = title
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

extension CreateTravelViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.travelTitleField.resignFirstResponder()
        return true
    }
}
