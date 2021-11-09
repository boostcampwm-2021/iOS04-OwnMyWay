//
//  NextButton.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import UIKit

class NextButton: UIButton {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureBackgroundColor()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureBackgroundColor()
    }

    private func configureBackgroundColor() {
        guard let backgroundColor = UIColor(named: "IdentityBlue") else {
            return
        }
        self.layoutIfNeeded()
        self.setBackgroundColor(backgroundColor, for: .normal)
    }

    func setAvailability(to isEnable: Bool) {
        self.isEnabled = isEnable
        self.backgroundColor = isEnable ? UIColor(named: "IdentityBlue") ?? .blue : .gray
    }

}

extension NextButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(backgroundImage, for: state)
    }
}
