//
//  UIViewController+.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/23.
//

import UIKit

extension UIViewController {

    func showToast(message: String) {
        let toastLabel = self.createToastLabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont(
            name: "Apple SD 산돌고딕 Neo",
            size: 15
        ) ?? UIFont.systemFont(ofSize: 15)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: {
            toastLabel.alpha = 0.0
        }, completion: { _ in
            toastLabel.removeFromSuperview()
        })
    }

    private func createToastLabel() -> UILabel {
        return UILabel(
            frame: CGRect(
                x: self.view.frame.size.width / 2 - 75,
                y: self.view.frame.size.height - 100,
                width: 150,
                height: 35
            )
        )
    }
}
