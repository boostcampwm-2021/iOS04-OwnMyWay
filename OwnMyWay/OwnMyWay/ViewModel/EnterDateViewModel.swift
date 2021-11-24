//
//  EnterDateViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/23.
//

import Foundation

protocol EnterDateViewModel {
    var travel: Travel { get }
    var isEditingMode: Bool { get }
    var calendarStatePublisher: Published<CalendarState>.Publisher { get }
    func viewDidLoad(completion: (Date?, Date?) -> Void)
    func travelDidChanged(to travel: Travel)
    func didEnterDate(at date: Date)
    func didTouchNoButton()
    func didTouchNextButton()
    func didTouchBackButton()
}

protocol EnterDateCoordinatingDelegate: AnyObject {
    func pushToAddLandmark(travel: Travel, isEditingMode: Bool)
    func popToCreateTravel(travel: Travel)
}

enum CalendarState {
    case fulfilled, firstDateEntered, empty, datesExisted
}

class DefaultEnterDateViewModel: EnterDateViewModel, ObservableObject {
    var calendarStatePublisher: Published<CalendarState>.Publisher { $calendarState }
    @Published private var calendarState: CalendarState = .datesExisted

    private let usecase: EnterDateUsecase
    private weak var coordinatingDelegate: EnterDateCoordinatingDelegate?
    private(set) var travel: Travel
    private(set) var isEditingMode: Bool
    private var firstDate: Date?

    init(
        usecase: EnterDateUsecase,
        coordinatingDelegate: EnterDateCoordinatingDelegate,
        travel: Travel,
        isEditingMode: Bool
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.isEditingMode = isEditingMode
        self.travel = travel
        if travel.startDate != nil, travel.endDate != nil {
            calendarState = .datesExisted
        } else {
            calendarState = .empty
        }
    }

    func viewDidLoad(completion: (Date?, Date?) -> Void) {
        completion(self.travel.startDate, self.travel.endDate)
    }

    func travelDidChanged(to travel: Travel) {
        self.travel = travel
    }

    func didEnterDate(at date: Date) {
        switch self.calendarState {
        case .fulfilled, .datesExisted:
            self.travel.startDate = nil
            self.travel.endDate = nil
            self.calendarState = .empty
        case .firstDateEntered:
            guard let firstDate = firstDate else { return }
            self.usecase.executeEnteringDate(
                firstDate: firstDate,
                secondDate: date
            ) { dates in
                self.firstDate = nil
                self.travel.startDate = dates.first
                self.travel.endDate = dates.last
                self.calendarState = .fulfilled
            }
        case .empty:
            self.firstDate = date
            self.calendarState = .firstDateEntered
        }
    }

    func didTouchNextButton() {
        self.coordinatingDelegate?.pushToAddLandmark(
            travel: self.travel, isEditingMode: self.isEditingMode
        )
    }

    func didTouchNoButton() {
        self.firstDate = nil
        self.travel.startDate = nil
        self.travel.endDate = nil
        self.calendarState = .empty
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToCreateTravel(travel: self.travel)
    }
}
