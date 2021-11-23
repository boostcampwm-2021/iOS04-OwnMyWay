//
//  DetailImageViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import Foundation

protocol DetailImageViewModel {
    var imageURLs: [URL] { get }
    func didTouchBackButton()
}

protocol DetailImageCoordinatingDelegate {
    func dismissToImageDetail()
}

class DefaultDetailImageViewModel: DetailImageViewModel {
    var imageURLs: [URL]
    var coordinatingDelegate: DetailImageCoordinatingDelegate?

    init(images: [URL], coordinatingDelegate: DetailImageCoordinatingDelegate) {
        self.coordinatingDelegate = coordinatingDelegate
        self.imageURLs = images
    }
    
    func didTouchBackButton() {
        self.coordinatingDelegate?.dismissToImageDetail()
    }
}
