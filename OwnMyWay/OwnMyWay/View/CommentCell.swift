//
//  CommentCell.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/11.
//

import UIKit

final class CommentCell: UICollectionViewCell {
    static let identifier = "CommentCell"

    @IBOutlet private weak var commentLabel: UILabel!

    func configure(text: String) {
        self.commentLabel.text = text
    }
}
