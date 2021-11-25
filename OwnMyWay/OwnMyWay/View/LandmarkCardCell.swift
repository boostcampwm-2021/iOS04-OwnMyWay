//
//  LandmarkCardCell.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import UIKit

class LandmarkCardCell: UICollectionViewCell {
    static let identifier: String = "LandmarkCardCell"

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func prepareForReuse() {
        self.imageView.image = nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 10.0
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = 10.0
    }

    func configure(with landmark: Landmark) {
        self.imageView.setNetworkImage(with: landmark.image)
        self.titleLabel.text = landmark.title
        self.configureAccessibility(with: landmark)
    }

    func configureAccessibility(with landmark: Landmark) {
        guard let title = landmark.title
        else { return }
        self.isAccessibilityElement = true
        self.accessibilityValue = "관광명소: \(title)"
    }

    func shake() {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnimation.duration = 0.05
        shakeAnimation.repeatCount = 2
        shakeAnimation.autoreverses = true
        let startAngle: Float =  -3.14159 / 180
        let stopAngle = -startAngle
        shakeAnimation.fromValue = NSNumber(value: startAngle as Float)
        shakeAnimation.toValue = NSNumber(value: 2 * stopAngle as Float)
        shakeAnimation.autoreverses = true
        shakeAnimation.duration = 0.15
        shakeAnimation.repeatCount = 10000
        shakeAnimation.timeOffset = 290 * Double.random(in: 0...1)

        let layer: CALayer = self.layer
        layer.add(shakeAnimation, forKey: "shaking")
    }

    func stopShaking() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
    }
}
