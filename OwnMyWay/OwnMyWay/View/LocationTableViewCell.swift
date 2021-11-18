//
//  LocationTableViewCell.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/18.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    static let identifier = "LocationTableViewCell"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    func configure(title: String?, subTitle: String?) {
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
    }
}
