//
//  LandmarkCartViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/02.
//

import Combine
import Foundation

protocol LandmarkCartViewModelType {
    var landmarks: [Landmark] { get set }

    func didAddLandmark(of landmark: Landmark)
    func didLinkLandmark(to travel: Travel, of landmark: Landmark, completion: (Error) -> Void)
    func didTouchBackButton(travel: Travel)
    func didDeleteLandmark(of index: Int)
}

class LandmarkCartViewModel: LandmarkCartViewModelType, ObservableObject {
    @Published var landmarks: [Landmark]

    private let landmarkCartUsecase: LandmarkCartUsecase

    init(landmarkCartUsecase: LandmarkCartUsecase) {
        self.landmarks = [Landmark]()
        self.landmarkCartUsecase = landmarkCartUsecase
    }

    func didAddLandmark(of landmark: Landmark) {
        self.landmarks.append(landmark)
    }

    func didLinkLandmark(to travel: Travel, of landmark: Landmark, completion: (Error) -> Void) {
        self.landmarkCartUsecase.addLandmark(to: travel, of: landmark, completion: completion)
    }

    func didTouchBackButton(travel: Travel) {
        self.landmarkCartUsecase.delete(of: travel)
    }

    func didDeleteLandmark(of index: Int) {
        self.landmarkCartUsecase.delete(of: landmarks[index])
    }
}
