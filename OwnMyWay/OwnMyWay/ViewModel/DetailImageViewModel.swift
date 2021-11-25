//
//  DetailImageViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import Foundation

protocol DetailImageViewModel {
    var imageIDs: [String] { get }
    var selectedIndex: Int { get }
    func didTouchBackButton()
}

protocol DetailImageCoordinatingDelegate: AnyObject {
    func dismissToImageDetail()
}

final class DefaultDetailImageViewModel: DetailImageViewModel {
    var imageIDs: [String]
    var selectedIndex: Int
    private weak var coordinatingDelegate: DetailImageCoordinatingDelegate?

    init(coordinatingDelegate: DetailImageCoordinatingDelegate, images: [String], index: Int) {
        self.coordinatingDelegate = coordinatingDelegate
        self.imageIDs = images
        self.selectedIndex = index
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.dismissToImageDetail()
    }
}
