//
//  MessageCell.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/23.
//

import UIKit

protocol MessageCellDelegate: AnyObject {
    func didTouchButton()
}

class MessageCell: UICollectionViewCell {
    static let identifier = "MessageCell"

    @IBOutlet private weak var createTravelButton: UIButton!
    private weak var delegate: MessageCellDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        self.createTravelButton.layer.cornerRadius = 10
    }

    func bind(delegate: MessageCellDelegate) {
        self.delegate = delegate
    }

    @IBAction func didTouchCreateTravelButton(_ sender: UIButton) {
        self.delegate?.didTouchButton()
    }

}
