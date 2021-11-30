//
//  LandmarkCartViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/02.
//

import Combine
import Foundation

enum SuperVC {
    case create
    case reserved
}

protocol LandmarkCartViewModel: TravelUpdatable {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }
    var superVC: SuperVC { get }
    func didAddLandmark(with landmark: Landmark)
    func didDeleteLandmark(at index: Int) -> Landmark
    func didTouchPlusButton()
    func findLandmark(at index: Int) -> Landmark
}

final class DefaultLandmarkCartViewModel: LandmarkCartViewModel,
                                    ObservableObject {

    @Published private(set) var travel: Travel
    var travelPublisher: Published<Travel>.Publisher { $travel }
    var superVC: SuperVC

    private weak var coordinatingDelegate: LandmarkCartCoordinatingDelegate?

    init(
        coordinatingDelegate: LandmarkCartCoordinatingDelegate,
        travel: Travel,
        superVC: SuperVC
    ) {
        self.coordinatingDelegate = coordinatingDelegate
        self.travel = travel
        self.superVC = superVC
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
