//
//  CreateTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import FSCalendar
import UIKit

class CreateTravelViewController: UIViewController, Instantiable {

    @IBOutlet private weak var travelTitleField: UITextField!
    @IBOutlet private weak var calendarView: FSCalendar!
    @IBOutlet private weak var nextButton: UIButton!

    private var prevDate: Date?
    private var isSelectionComplete: Bool = false
    private var viewModel: CreateTravelViewModelType?
    var coordinator: CreateTravelCoordinator?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUsecase()
        self.bindUI()
        self.configureCalendar()
    }

    private func setUsecase() {
        let usecase = DefaultCreateTravelUsecase(travelRepository: CoreDataTravelRepository())
        self.viewModel = CreateTravelViewModel(createTravelUsecase: usecase)
    }

    private func bindUI() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { isValid in
                self.nextButton.isEnabled = isValid ?? false
            }
            .store(in: &cancellables)
    }

    private func configureCalendar() {
        self.calendarView.placeholderType = FSCalendarPlaceholderType.none
    }

    @IBAction func editingDidEnd(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(text: sender.text)
        sender.resignFirstResponder()
    }

    @IBAction func nextButtonDidTouched(_ sender: UIButton) {
        self.viewModel?.didTouchNextButton(completion: { [weak self] _ in
            self?.coordinator?.pushToAddLandmark()
        })
    }

}

extension CreateTravelViewController: FSCalendarDelegate {

    func calendar(_ calendar: FSCalendar,
                  didSelect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        if isSelectionComplete {
            initSelection()
            return
        }
        if let selectedDate = prevDate {
            let startDate = selectedDate > date ? date : selectedDate
            let endDate = selectedDate > date ? selectedDate : date
            let message = "여행 기간을 \(localize(date: startDate))부터 \(localize(date: endDate))로 설정할까요?"
            let alert = UIAlertController(title: "여행기간 확정",
                                          message: message,
                                          preferredStyle: .alert)
            let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
                let dayInterval: TimeInterval = 60 * 60 * 24
                stride(from: startDate, through: endDate, by: dayInterval).forEach {
                    calendar.select($0)
                }
                self?.isSelectionComplete = true
                self?.viewModel?.didEnterDate(from: startDate, to: endDate)
            }
            let noAction = UIAlertAction(title: "아니오", style: .cancel) { [weak self] _ in
                calendar.deselect(selectedDate)
                calendar.deselect(date)
                self?.prevDate = nil
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            present(alert, animated: true)
        }
        prevDate = date
    }

    func calendar(_ calendar: FSCalendar,
                  didDeselect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        initSelection()
    }

    private func initSelection() {
        calendarView.deselectAll()
        prevDate = nil
        isSelectionComplete = false
        self.viewModel?.didEnterDate(from: nil, to: nil)
    }

    private func localize(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

}

extension Date: Strideable {

    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by interval: TimeInterval) -> Date {
        return self + interval
    }

}

extension FSCalendar {

    func deselectAll() {
        let dates = self.selectedDates
        dates.forEach { [weak self] date in
            self?.deselect(date)
        }
    }

}