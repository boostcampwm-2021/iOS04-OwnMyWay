//
//  UIView+.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/17.
//

import UIKit

extension UIView {
    func makeShadow() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray6.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowColor = UIColor.systemGray5.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 3)
        self.layer.shadowRadius = 3
        self.layer.masksToBounds = false
    }

    func makePolaroid(with record: Record) {
        let photoImageView = UIImageView()
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.setImage(with: record.photoURLs?.first)

        let titleLabel = UILabel()
        titleLabel.text = record.content
        titleLabel.font = UIFont(name: "Chalkduster", size: 17)

        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(photoImageView)
        self.addSubview(titleLabel)

        self.makeShadow()

        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(
                equalTo: self.topAnchor,
                constant: 20
            ),
            photoImageView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 20
            ),
            photoImageView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -20
            ),
            photoImageView.heightAnchor.constraint(
                equalTo: photoImageView.widthAnchor,
                multiplier: 0.75
            ),
            titleLabel.topAnchor.constraint(
                equalTo: photoImageView.bottomAnchor,
                constant: 15
            ),
            titleLabel.bottomAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: -15
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: self.leadingAnchor,
                constant: 24
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: -24
            )
        ])

        self.layoutIfNeeded()
    }
}
