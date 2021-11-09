//
//  CreateTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import Foundation

protocol CreateTravelViewModel {
    var validatePublisher: Published<Bool?>.Publisher { get }
    var startDatePublisher: Published<String?>.Publisher { get }
    var endDatePublisher: Published<String?>.Publisher { get }

    func travelDidChanged(to travel: Travel)
    func didEnterTitle(text: String?)
    func didEnterDate(from startDate: Date?, to endDate: Date?)
    func didTouchNextButton()
}

protocol CreateTravelCoordinatingDelegate: AnyObject {
    func pushToAddLandmark(travel: Travel)
}

class DefaultCreateTravelViewModel: CreateTravelViewModel, ObservableObject {
    var validatePublisher: Published<Bool?>.Publisher { $validateResult }
    var startDatePublisher: Published<String?>.Publisher { $startDate }
    var endDatePublisher: Published<String?>.Publisher { $endDate }

    private let usecase: CreateTravelUsecase
    private weak var coordinatingDelegate: CreateTravelCoordinatingDelegate?

    @Published private var validateResult: Bool?
    @Published private var startDate: String?
    @Published private var endDate: String?
    private var travel: Travel
    private var travelTitle: String?
    private var travelStartDate: Date?
    private var travelEndDate: Date?
    private var isValidTitle: Bool = false {
        didSet {
            validateResult = isValidTitle && isValidDate
        }
    }
    private var isValidDate: Bool = false {
        didSet {
            validateResult = isValidTitle && isValidDate
        }
    }

    init(usecase: CreateTravelUsecase, coordinatingDelegate: CreateTravelCoordinatingDelegate) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.travel = Travel.dummy()
    }

    func travelDidChanged(to travel: Travel) {
        self.travel = travel
    }

    func didEnterTitle(text: String?) {
        guard let text = text else { return }
        self.usecase.executeTitleValidation(with: text) { [weak self] result in
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
        self.coordinatingDelegate?.pushToAddLandmark(travel: self.travel)
    }
}
