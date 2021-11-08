//
//  LandmarkCartViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/02.
//

import Combine
import Foundation

protocol LandmarkCartViewModelType {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }
    func didAddLandmark(of landmark: Landmark)
    func plusButtonDidTouched()
}

protocol LandmarkCartCoordinatingDelegate: AnyObject {
    func presentSearchLandmarkModally()
}

class LandmarkCartViewModel: LandmarkCartViewModelType, ObservableObject {
    @Published private(set) var travel: Travel
    var travelPublisher: Published<Travel>.Publisher { $travel }

    private let landmarkCartUsecase: LandmarkCartUsecase
    private weak var coordinator: LandmarkCartCoordinatingDelegate?

    init(
        landmarkCartUsecase: LandmarkCartUsecase,
        coordinator: LandmarkCartCoordinatingDelegate,
        travel: Travel
    ) {
        self.travel = travel
        self.coordinator = coordinator
        self.landmarkCartUsecase = landmarkCartUsecase
    }

    func didAddLandmark(of landmark: Landmark) {
        self.landmarkCartUsecase.addLandmark(to: self.travel, of: landmark) { landmark in
            self.travel.landmarks.append(landmark)
        }
    }

    func plusButtonDidTouched() {
        self.coordinator?.presentSearchLandmarkModally()
    }
}
