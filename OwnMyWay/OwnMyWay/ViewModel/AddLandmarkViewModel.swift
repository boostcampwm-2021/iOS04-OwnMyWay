//
//  AddLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/08.
//

import Foundation

protocol AddLandmarkViewModel {
    var travel: Travel { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    var isEditingMode: Bool { get }

    func didTouchNextButton()
    func didTouchBackButton()
    func didUpdateTravel(to travel: Travel)
    func didDeleteLandmark(at landmark: Landmark)
}

protocol AddLandmarkCoordinatingDelegate: AnyObject {
    func pushToCompleteCreation(travel: Travel)
    func pushToCompleteEditing(travel: Travel)
    func popToEnterDate(travel: Travel)
}

class DefaultAddLandmarkViewModel: AddLandmarkViewModel {
    var errorPublisher: Published<Error?>.Publisher { $error }
    private(set) var travel: Travel

    private(set) var isEditingMode: Bool
    @Published private var error: Error?

    private weak var coordinatingDelegate: AddLandmarkCoordinatingDelegate?

    init(
        travel: Travel, coordinatingDelegate: AddLandmarkCoordinatingDelegate, isEditingMode: Bool
    ) {
        self.travel = travel
        self.coordinatingDelegate = coordinatingDelegate
        self.isEditingMode = isEditingMode
    }

    func didTouchNextButton() {
        if self.isEditingMode {
            self.coordinatingDelegate?.pushToCompleteEditing(travel: travel)
        } else {
            self.coordinatingDelegate?.pushToCompleteCreation(travel: travel)
        }
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToEnterDate(travel: travel)
    }

    func didUpdateTravel(to travel: Travel) {
        self.travel = travel
    }

    func didDeleteLandmark(at landmark: Landmark) {
        guard let index = self.travel.landmarks.firstIndex(of: landmark) else {
            self.error = ModelError.indexError
            return
        }
        self.travel.landmarks.remove(at: index)
    }
}
