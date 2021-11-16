//
//  AddRecordViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class AddRecordViewController: UIViewController, Instantiable {

    private var viewModel: AddRecordViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureGestureRecognizer()
        self.configureNotifications()
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }
}

extension AddRecordViewController {
    private func configureGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowAction(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideAction(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func deleteNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc private func keyboardWillShowAction(_ notification: Notification) {
        let optDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        let optSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard let duration = optDuration as? Double,
              let keyboard = (optSize as? NSValue)?.cgRectValue
        else { return }
        let height = keyboard.height - self.view.safeAreaInsets.bottom

        UIView.animate(withDuration: duration) {
            self.view.frame.move(horizontal: 0, vertical: -height)
        }
    }

    @objc private func keyboardWillHideAction(_ notification: Notification) {
        let optDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        guard let duration = optDuration as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.view.frame.moveToZero()
        }
    }
}

fileprivate extension CGRect {
    mutating func move(horizontal: CGFloat, vertical: CGFloat) {
        self = CGRect(
            origin: CGPoint(x: self.origin.x + horizontal, y: self.origin.y + vertical),
            size: self.size
        )
    }

    mutating func moveToZero() {
        self = CGRect(origin: .zero, size: self.size)
    }
}
