//
//  OMWCollectionViewCell.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/25.
//

import UIKit

class OMWCollectionViewCell: UICollectionViewCell {
    var downloadTask: Cancellable?

    override func prepareForReuse() {
        self.downloadTask?.cancelFetch()
    }
}
