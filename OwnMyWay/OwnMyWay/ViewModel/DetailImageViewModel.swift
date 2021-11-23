//
//  DetailImageViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import Foundation

protocol DetailImageViewModel {
    var imageURLs: [URL] { get }
}

protocol DetailImageCoordinatingDelegate {
    
}

class DefaultDetailImageViewModel: DetailImageViewModel {
    var imageURLs: [URL]

    init(images: [URL]) {
        self.imageURLs = images
    }
}
