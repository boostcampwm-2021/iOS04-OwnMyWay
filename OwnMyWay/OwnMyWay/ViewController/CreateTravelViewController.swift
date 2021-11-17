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
    @IBOutlet private weak var nextButton: NextButton!
    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: CreateTravelViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private var prevDate: Date?
    private var isSelectionComplete: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCancellable()
        self.configureCalendar()
        self.configureGestureRecognizer()
        self.travelTitleField.delegate = self
        self.configureLabels()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: CreateTravelViewModel) {
        self.viewModel = viewModel
    }

    func travelDidChanged(to travel: Travel) {
        self.viewModel?.travelDidChanged(to: travel)
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.nextButton.setAvailability(to: isValid ?? false)
            }
            .store(in: &cancellables)
    }

    private func configureCalendar() {
        self.calendarView.placeholderType = FSCalendarPlaceholderType.none
    }

    private func configureLabels() {
        self.viewModel?.viewDidLoad { [weak self] title, startDate, endDate in
            guard let title = title,
                  let startDate = startDate,
                  let endDate = endDate
            else { return }
            self?.navigationItem.title = "기록 편집하기"
            self?.travelTitleField.text = title
            let dayInterval: TimeInterval = 60 * 60 * 24
            stride(from: startDate, through: endDate, by: dayInterval).forEach {
                self?.calendarView.select($0)
            }
        }
    }

    private func configureGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didChangeTitle(text: sender.text)
    }

    @IBAction func didTouchNextButton(_ sender: UIButton) {
        self.viewModel?.didTouchNextButton()
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
            presentAlert(calendar: calendar, from: startDate, to: endDate)
        }
        prevDate = date
    }

    func calendar(_ calendar: FSCalendar,
                  didDeselect date: Date,
                  at monthPosition: FSCalendarMonthPosition) {
        if isSelectionComplete {
            initSelection()
            return
        }
        presentAlert(calendar: calendar, from: date, to: date)
    }

    private func presentAlert(calendar: FSCalendar, from startDate: Date, to endDate: Date) {
        let alert = UIAlertController(
            title: "여행기간 확정",
            message: self.alertMessage(startDate: startDate, endDate: endDate),
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            let dayInterval: TimeInterval = 60 * 60 * 24
            stride(from: startDate, through: endDate, by: dayInterval).forEach {
                calendar.select($0)
            }
            self?.isSelectionComplete = true
            self?.viewModel?.didEnterDate(from: startDate, to: endDate)
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel) { [weak self] _ in
            calendar.deselect(startDate)
            calendar.deselect(endDate)
            self?.prevDate = nil
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }

    private func alertMessage(startDate: Date, endDate: Date) -> String {
        if startDate == endDate {
            return "여행 기간을 \(startDate.localize()) 당일치기로 설정할까요?"
        }
        return "여행 기간을 \(startDate.localize())부터 \(endDate.localize())로 설정할까요?"
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

extension CreateTravelViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.travelTitleField.resignFirstResponder()
        return true
    }

}

fileprivate extension FSCalendar {

    func deselectAll() {
        let dates = self.selectedDates
        dates.forEach { [weak self] date in
            self?.deselect(date)
        }
    }

}
