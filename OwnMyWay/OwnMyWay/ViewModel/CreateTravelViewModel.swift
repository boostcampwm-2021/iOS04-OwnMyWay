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

    func viewDidLoad(completion: (String?, Date?, Date?) -> Void)
    func travelDidChanged(to travel: Travel)
    func didChangeTitle(text: String?)
    func didEnterDate(from startDate: Date?, to endDate: Date?)
    func didTouchNextButton()
}

protocol CreateTravelCoordinatingDelegate: AnyObject {
    func pushToAddLandmark(travel: Travel, isEditingMode: Bool)
}

class DefaultCreateTravelViewModel: CreateTravelViewModel, ObservableObject {
    var validatePublisher: Published<Bool?>.Publisher { $validateResult }

    private let usecase: CreateTravelUsecase
    private weak var coordinatingDelegate: CreateTravelCoordinatingDelegate?

    @Published private var validateResult: Bool?

    private var travel: Travel
    private var travelTitle: String?
    private var travelStartDate: Date?
    private var travelEndDate: Date?
    private var isEditingMode: Bool
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

    init(
        usecase: CreateTravelUsecase,
        coordinatingDelegate: CreateTravelCoordinatingDelegate,
        travel: Travel?
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.isEditingMode = travel == nil ? false : true
        self.travel = travel ?? Travel.dummy(section: .reserved)
        self.didEnterTitle(text: travel?.title)
        self.didEnterDate(from: travel?.startDate, to: travel?.endDate)
    }

    func viewDidLoad(completion: (String?, Date?, Date?) -> Void) {
        completion(self.travelTitle, self.travelStartDate, self.travelEndDate)
    }

    func travelDidChanged(to travel: Travel) {
        self.travel = travel
    }

    func didChangeTitle(text: String?) {
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
        self.coordinatingDelegate?.pushToAddLandmark(
            travel: self.travel, isEditingMode: self.isEditingMode
        )
    }
}
