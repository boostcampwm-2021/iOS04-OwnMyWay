//
//  PlusCell.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/02.
//

import UIKit

class PlusCell: UICollectionViewCell {
    static let identifier = "PlusCell"

    private var dashedLayer: CAShapeLayer?

    func configure() {
        self.drawDottedLayer()
    }

    private func drawDottedLayer() {
        self.dashedLayer?.removeFromSuperlayer()

        let shapeLayer: CAShapeLayer = {
            let shapeLayer = CAShapeLayer()

            shapeLayer.frame = self.bounds
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
            shapeLayer.lineWidth = 2
            shapeLayer.lineDashPattern = [6, 3]
            shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath

            return shapeLayer
        }()

        let maskLayer: CAShapeLayer = {
           let maskLayer = CAShapeLayer()

            maskLayer.frame = self.bounds
            maskLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath

            return maskLayer
        }()

        self.dashedLayer = shapeLayer
        self.layer.mask = maskLayer
        self.layer.addSublayer(shapeLayer)
    }
}
