//
//  EnterDateViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/23.
//

import Foundation

protocol EnterDateViewModel {
    var travel: Travel { get }
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
    case fullfill, firstDateEntered, empty, existDates
}

class DefaultEnterDateViewModel: EnterDateViewModel, ObservableObject {
    var calendarStatePublisher: Published<CalendarState>.Publisher { $calendarState }
    @Published private var calendarState: CalendarState = .existDates

    private let usecase: EnterDateUsecase
    private weak var coordinatingDelegate: EnterDateCoordinatingDelegate?
    private(set) var travel: Travel
    private var firstDate: Date?
    private var isEditingMode: Bool

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
            calendarState = .existDates
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
        if self.travel.startDate != nil, self.travel.endDate != nil { // 두 개의 날짜가 입력되어 있을 때
            self.travel.startDate = nil
            self.travel.endDate = nil
            self.calendarState = .empty
        } else if let firstDate = self.firstDate { // 한 개의 날짜만 입력되어 있을 때
            self.usecase.executeEnteringDate(
                firstDate: firstDate,
                secondDate: date
            ) { dates in
                self.firstDate = nil
                self.travel.startDate = dates.first
                self.travel.endDate = dates.last
                self.calendarState = .fullfill
            }
        } else { // 비어 있을 때
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
