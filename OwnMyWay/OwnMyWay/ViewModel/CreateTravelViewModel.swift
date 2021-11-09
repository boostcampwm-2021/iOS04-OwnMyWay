//
//  CreateTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import Foundation

protocol CreateTravelViewModelType {
    var validatePublisher: Published<Bool?>.Publisher { get }
    var startDatePublisher: Published<String?>.Publisher { get }
    var endDatePublisher: Published<String?>.Publisher { get }

    func didUpdateTravel(travel: Travel)
    func didEnterTitle(text: String?)
    func didEnterDate(from startDate: Date?, to endDate: Date?)
    func didTouchNextButton()
}

protocol CreateTravelCoordinatingDelegate: AnyObject {
    func pushToAddLandmark(travel: Travel)
}

class CreateTravelViewModel: CreateTravelViewModelType, ObservableObject {
    var travelTitle: String?
    var travelStartDate: Date?
    var travelEndDate: Date?
    var isValidTitle: Bool = false {
        didSet {
            validateResult = isValidTitle && isValidDate
        }
    }

    var isValidDate: Bool = false {
        didSet {
            validateResult = isValidTitle && isValidDate
        }
    }

    @Published private var validateResult: Bool?
    @Published private var startDate: String?
    @Published private var endDate: String?

    var validatePublisher: Published<Bool?>.Publisher { $validateResult }
    var startDatePublisher: Published<String?>.Publisher { $startDate }
    var endDatePublisher: Published<String?>.Publisher { $endDate }

    private let createTravelUsecase: CreateTravelUsecase
    private weak var coordinator: CreateTravelCoordinatingDelegate?
    private var travel: Travel

    init(createTravelUsecase: CreateTravelUsecase, coordinator: CreateTravelCoordinatingDelegate) {
        self.createTravelUsecase = createTravelUsecase
        self.coordinator = coordinator
        self.travel = Travel(
            uuid: nil,
            flag: 0,
            title: "",
            startDate: Date(),
            endDate: Date(),
            landmarks: [],
            records: []
        )
    }

    func didUpdateTravel(travel: Travel) {
        self.travel = travel
    }

    func didEnterTitle(text: String?) {
        guard let text = text else { return }
        self.createTravelUsecase.configureTravelTitle(text: text) { [weak self] result in
            switch result {
            case .success(let title):
                self?.travelTitle = title
                self?.isValidTitle = true
            case .failure:
                self?.isValidTitle = false
            }
        }
    }

    func didEnterDate(from startDate: Date?, to endDate: Date?) {
        self.travelStartDate = startDate
        self.travelEndDate = endDate
        var isValid = false
        if let startDate = startDate,
           let endDate = endDate,
           startDate <= endDate {
            isValid = true
        }
        self.isValidDate = isValid
    }

    func didTouchNextButton() {
        self.travel.title = self.travelTitle
        self.travel.startDate = self.travelStartDate
        self.travel.endDate = self.travelEndDate
        self.coordinator?.pushToAddLandmark(travel: self.travel)
    }
}
