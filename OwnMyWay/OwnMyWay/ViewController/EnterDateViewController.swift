//
//  EnterDateViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/23.
//

import Combine
import UIKit
import FSCalendar

final class EnterDateViewController: UIViewController, Instantiable {

    @IBOutlet private weak var calendarView: OMWCalendar!
    @IBOutlet private weak var nextButton: NextButton!
    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: EnterDateViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLabels()
        self.configureCalendar()
        self.configureCancellable()
        self.nextButton.setAvailability(to: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationController()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    private func configureNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = ""
        guard let isEditingMode = self.viewModel?.isEditingMode else { return }
        self.navigationItem.title = isEditingMode ? "여행 편집하기" : "새로운 여행"
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureCancellable() {
        self.viewModel?.calendarStatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                switch state {
                case .datesExisted:
                    self?.nextButton.setAvailability(to: true)
                case .fulfilled:
                    self?.presentAlert(calendar: self?.calendarView)
                    self?.nextButton.setAvailability(to: true)
                case .firstDateEntered:
                    self?.nextButton.setAvailability(to: false)
                case .empty:
                    self?.calendarView.deselectAll()
                    self?.nextButton.setAvailability(to: false)
                }
            }
            .store(in: &cancellables)
    }

    private func configureCalendar() {
        self.calendarView.delegate = self
    }

    private func configureLabels() {
        self.viewModel?.viewDidLoad { [weak self] startDate, endDate in
            guard let startDate = startDate,
                  let endDate = endDate
            else { return }
            self?.navigationItem.title = "기록 편집하기"
//            let dayInterval: TimeInterval = 60 * 60 * 24
//            stride(from: startDate, through: endDate, by: dayInterval).forEach {
//                self?.calendarView.select($0)
//            }
            self?.calendarView.selectDate(date: startDate)
            self?.calendarView.selectDate(date: endDate)
            self?.calendarView.reloadCalendar()
        }
    }

    func bind(viewModel: EnterDateViewModel) {
        self.viewModel = viewModel
    }

    func travelDidChanged(to travel: Travel) {
        self.viewModel?.travelDidChanged(to: travel)
    }

    @IBAction func didTouchNextButton(_ sender: Any) {
        self.viewModel?.didTouchNextButton()
    }
}

extension EnterDateViewController: OMWCalendarDelegate {
    func didSelect(date: Date) {
        self.viewModel?.didEnterDate(at: date)
    }

    private func presentAlert(calendar: OMWCalendar?) {
        guard let calendar = calendar,
              let startDate = self.viewModel?.travel.startDate,
              let endDate = self.viewModel?.travel.endDate
        else { return }

        let alert = UIAlertController(
            title: "여행기간 확정",
            message: self.alertMessage(startDate: startDate, endDate: endDate),
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "네", style: .destructive) { _ in
            self.calendarView.reloadCalendar()
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel) { [weak self] _ in
            self?.viewModel?.didTouchNoButton()
            calendar.deselectAll()
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

    private func alertMessage(startDate: Date, endDate: Date) -> String {
        if startDate == endDate {
            return "여행 기간을 \(startDate.localize()) 당일치기로 설정할까요?"
        }
        return "여행 기간을 \(startDate.localize())부터 \(endDate.localize())로 설정할까요?"
    }
}
