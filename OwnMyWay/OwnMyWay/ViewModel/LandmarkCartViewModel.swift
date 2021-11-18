//
//  LandmarkCartViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/02.
//

import Combine
import Foundation

protocol LandmarkCartViewModel: TravelUpdatable {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }

    func didAddLandmark(with landmark: Landmark)
    func didDeleteLandmark(at index: Int) -> Landmark
    func didTouchPlusButton()
    func findLandmark(at index: Int) -> Landmark
}

protocol LandmarkCartCoordinatingDelegate: AnyObject {
    func presentSearchLandmarkModally()
}

class DefaultLandmarkCartViewModel: LandmarkCartViewModel,
                                    ObservableObject {

    @Published private(set) var travel: Travel
    var travelPublisher: Published<Travel>.Publisher { $travel }

    private weak var coordinatingDelegate: LandmarkCartCoordinatingDelegate?

    init(
        coordinatingDelegate: LandmarkCartCoordinatingDelegate,
        travel: Travel
    ) {
        self.coordinatingDelegate = coordinatingDelegate
        self.travel = travel
    }

    func didAddLandmark(with landmark: Landmark) {
        self.travel.landmarks.append(landmark)
    }

    func didTouchPlusButton() {
        self.coordinatingDelegate?.presentSearchLandmarkModally()
    }

    func didDeleteLandmark(at index: Int) -> Landmark {
        return self.travel.landmarks.remove(at: index)
    }

    func findLandmark(at index: Int) -> Landmark {
        return self.travel.landmarks[index]
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel
    }
}
