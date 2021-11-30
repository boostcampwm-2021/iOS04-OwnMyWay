//
//  HomeBackgroundView.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/22.
//

import UIKit

final class HomeBackgroundView: UICollectionReusableView {
    static let identifier = "HomeBackgroundView"

    @IBOutlet private weak var backgroundView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    private func configure() {
        self.layer.cornerRadius = 25
    }

}
