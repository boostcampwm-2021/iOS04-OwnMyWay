//
//  DetailImageViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import Foundation

protocol DetailImageViewModel {
    var imageURLs: [URL] { get set }
    var selectedIndex: Int { get set }
    func didTouchBackButton()
}

protocol DetailImageCoordinatingDelegate: AnyObject {
    func dismissToImageDetail()
}

class DefaultDetailImageViewModel: DetailImageViewModel {
    var imageURLs: [URL]
    var selectedIndex: Int
    private weak var coordinatingDelegate: DetailImageCoordinatingDelegate?

    init(coordinatingDelegate: DetailImageCoordinatingDelegate, images: [URL], index: Int) {
        self.coordinatingDelegate = coordinatingDelegate
        self.imageURLs = images
        self.selectedIndex = index
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.dismissToImageDetail()
    }
}
