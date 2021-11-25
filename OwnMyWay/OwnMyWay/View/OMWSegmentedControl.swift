//
//  OMWSegmentController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/22.
//
import UIKit

protocol OMWSegmentedControlDelegate: AnyObject {
    func change(to index: Int)
}

final class OMWSegmentedControl: UIView {

    private var buttonTitles: [String] = []
    private var buttons: [UIButton] = []
    private var selectorView: UIView = UIView()

    private var textColor: UIColor = UIColor(named: "IdentityBlue") ?? .blue
    private var viewColor: UIColor = .white
    private var selectorViewColor: UIColor = UIColor(named: "IdentityBlue") ?? .blue
    private var selectorTextColor: UIColor = .white

    weak var delegate: OMWSegmentedControlDelegate?

    public private(set) var selectedIndex: Int = 0

    convenience init(frame: CGRect, buttonTitles: [String]) {
        self.init(frame: frame)
        self.buttonTitles = buttonTitles
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.borderWidth = 1
        self.layer.borderColor = self.selectorViewColor.cgColor
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        self.updateView()
    }

    @objc func didTouchButton(_ sender: UIButton) {

        for (buttonIndex, button) in self.buttons.enumerated() {
            button.setTitleColor(self.textColor, for: .normal)
            if button == sender {
                let buttonCount = self.buttonTitles.count
                let selectorPosition = frame.width / CGFloat(buttonCount) * CGFloat(buttonIndex)
                self.selectedIndex = buttonIndex
                self.delegate?.change(to: selectedIndex)
                self.selectorView.frame.origin.x = selectorPosition
                button.setTitleColor(self.selectorTextColor, for: .normal)
            }
        }
    }
}

extension OMWSegmentedControl {
    private func updateView() {
        self.createButton()
        self.configureSelectorView()
        self.configStackView()
    }

    private func configStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        self.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    private func configureSelectorView() {
        let selectorWidth = frame.width / CGFloat(self.buttonTitles.count)
        self.selectorView = UIView(
            frame:
                CGRect(
                    x: selectorWidth * CGFloat(selectedIndex),
                    y: 0,
                    width: selectorWidth,
                    height: frame.height
                )
        )
        self.selectorView.backgroundColor = self.selectorViewColor
        self.addSubview(self.selectorView)
    }

    private func createButton() {
        self.buttons = [UIButton]()
        self.buttons.removeAll()
        self.subviews.forEach { $0.removeFromSuperview() }
        self.buttonTitles.forEach { title in
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.addTarget(self, action: #selector(didTouchButton(_:)), for: .touchUpInside)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = self.textColor.cgColor
            button.layer.masksToBounds = true
            button.titleLabel?.font = UIFont(
                name: "Apple SD 산돌고딕 Neo",
                size: 15
            ) ?? UIFont.systemFont(ofSize: 15)
            button.setTitleColor(self.textColor, for: .normal)
            self.buttons.append(button)
        }
        self.buttons[self.selectedIndex].setTitleColor(self.selectorTextColor, for: .normal)
    }
}
