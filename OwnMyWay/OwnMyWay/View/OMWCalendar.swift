//
//  OMWCalendar.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/25.
//

import UIKit

protocol OMWCalendarDelegate: AnyObject {
    func didSelect(date: Date)
}

class CalendarDataSource: NSObject, UICollectionViewDataSource {
    var date: Date {
        didSet {
            var items = [CalendarItem]()
            for index in 0..<7 - date.firstWeekDayCount {
                items.append(CalendarItem(isDummy: true, date: date.addingTimeInterval(Double(index))))
            }
            for index in 0..<date.numberOfDays {
                items.append(CalendarItem(
                    isDummy: false,
                    date: date.firstDayOfTheMonth.addingTimeInterval(86400 * Double(index))
                ))
            }
            self.items = items
        }
    }
    private var items: [CalendarItem]
    private var startDate: Date?
    private var endDate: Date?

    override init() {
        self.date = Date()
        self.items = []
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CalendarCell.identifier, for: indexPath
        ) as? CalendarCell
        else { return UICollectionViewCell() }
        let item = self.items[indexPath.item]
        cell.configure(item: item)
        if let startDate = self.startDate,
           let endDate = self.endDate,
           startDate <= item.date && endDate >= item.date,
           !item.isDummy {
            cell.didSelect()
        }
        return cell
    }

    func configureDate(from startDate: Date?, to endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
    }

}

struct CalendarItem: Hashable {
    var isDummy: Bool
    var date: Date
}

class OMWCalendar: UIView {

    enum Section {
        case main
    }

    enum Direction {
        case left
        case right
        case none
    }

    weak var delegate: OMWCalendarDelegate?
    private var previousDataSource = CalendarDataSource()
    private var currentDataSource = CalendarDataSource()
    private var nextDataSource = CalendarDataSource()
    private var scrollDirection: Direction = .none
    private var currentMonth: Date = Date.init(timeIntervalSinceNow: 0) {
        didSet {
            self.configureCollectionViews()
            self.configureTitleLabel(with: self.currentMonth)
        }
    }
    private var startDate: Date?
    private var endDate: Date?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 18)
        return label
    }()

    private lazy var dateStack: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let dates = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        dates.forEach { date in
            let dateLabel = UILabel()
            dateLabel.text = date
            dateLabel.textAlignment = .center
            dateLabel.font = UIFont.init(name: "AppleSDGothicNeo-Regular", size: 18)
            stackView.addArrangedSubview(dateLabel)
        }
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()

    private lazy var previousCalendar: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: createCompositionalLayout()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self.previousDataSource
        self.configure(collectionView: collectionView)
        return collectionView
    }()

    private lazy var currentCalendar: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: createCompositionalLayout()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self.currentDataSource
        self.configure(collectionView: collectionView)
        return collectionView
    }()

    private lazy var nextCalendar: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero, collectionViewLayout: createCompositionalLayout()
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = false
        collectionView.dataSource = self.nextDataSource
        self.configure(collectionView: collectionView)
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureCalendar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureCalendar()
    }

    override func draw(_ rect: CGRect) {
        self.scrollView.scrollRectToVisible(self.currentCalendar.frame, animated: false)
    }

    func redraw() {
        self.configureCollectionViews()
        self.previousCalendar.reloadData()
        self.currentCalendar.reloadData()
        self.nextCalendar.reloadData()
    }

    func selectDate(date: Date) {
        if let startDate = startDate {
            self.startDate = startDate <= date ? startDate : date
            self.endDate = startDate <= date ? date : startDate
        } else {
            self.startDate = date
        }
    }

    func deselectAll() {
        self.deselectDate()
        self.configureCollectionViews()
    }

    private func deselectDate() {
        self.startDate = nil
        self.endDate = nil
    }

    private func configureCalendar() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.dateStack)
        self.addSubview(self.scrollView)
        self.scrollView.addSubview(self.previousCalendar)
        self.scrollView.addSubview(self.currentCalendar)
        self.scrollView.addSubview(self.nextCalendar)

        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.titleLabel.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1 / 7),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.dateStack.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
            self.dateStack.heightAnchor.constraint(equalTo: self.titleLabel.heightAnchor),
            self.dateStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.dateStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            self.scrollView.topAnchor.constraint(equalTo: self.dateStack.bottomAnchor),
            self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.previousCalendar.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            self.previousCalendar.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor),
            self.currentCalendar.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            self.currentCalendar.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor),
            self.nextCalendar.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
            self.nextCalendar.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor),
            self.currentCalendar.topAnchor.constraint(equalTo: self.previousCalendar.topAnchor),
            self.nextCalendar.topAnchor.constraint(equalTo: self.previousCalendar.topAnchor),
            self.currentCalendar.leadingAnchor.constraint(
                equalTo: self.previousCalendar.trailingAnchor
            ),
            self.nextCalendar.leadingAnchor.constraint(
                equalTo: self.currentCalendar.trailingAnchor
            ),
            self.scrollView.contentLayoutGuide.topAnchor.constraint(
                equalTo: self.previousCalendar.topAnchor
            ),
            self.scrollView.contentLayoutGuide.bottomAnchor.constraint(
                equalTo: self.previousCalendar.bottomAnchor
            ),
            self.scrollView.contentLayoutGuide.leadingAnchor.constraint(
                equalTo: self.previousCalendar.leadingAnchor
            ),
            self.scrollView.contentLayoutGuide.trailingAnchor.constraint(
                equalTo: self.nextCalendar.trailingAnchor
            )
        ])

        self.configureCollectionViews()
        self.configureTitleLabel(with: self.currentMonth)
    }

    private func configureCollectionViews() {
        self.previousDataSource.date = currentMonth.previousMonth
        self.previousDataSource.configureDate(from: self.startDate, to: self.endDate)
        self.previousCalendar.reloadData()
        self.currentDataSource.date = currentMonth
        self.currentDataSource.configureDate(from: self.startDate, to: self.endDate)
        self.currentCalendar.reloadData()
        self.nextDataSource.date = currentMonth.nextMonth
        self.nextDataSource.configureDate(from: self.startDate, to: self.endDate)
        self.nextCalendar.reloadData()
        self.scrollView.scrollRectToVisible(self.currentCalendar.frame, animated: false)
    }

    private func configureTitleLabel(with date: Date) {
        self.titleLabel.text = "\(date.year)년 \(date.month)월"
    }

    private func configure(collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.register(
            UINib(nibName: CalendarCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: CalendarCell.identifier
        )
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1 / 7), heightDimension: .fractionalWidth(1 / 7)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1 / 7)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item, item, item, item, item, item, item]
        )

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension OMWCalendar: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dayNumber = indexPath.item - 7 + currentMonth.firstWeekDayCount
        guard dayNumber >= 0
        else { return }
        let date = generateDate(
            year: currentMonth.year, month: currentMonth.month, dayNumber: dayNumber
        )
        self.delegate?.didSelect(date: date)
        if self.startDate != nil && self.endDate != nil {
            self.deselectAll()
        } else {
            guard let cell = collectionView.cellForItem(at: indexPath) as? CalendarCell
            else { return }
            cell.didSelect()
            self.selectDate(date: date)
        }
    }

    private func generateDate(year: Int, month: Int, dayNumber: Int) -> Date {
        return Calendar.current.date(
            from: DateComponents(year: year, month: month, day: dayNumber + 1)
        ) ?? Date()
    }

}

extension OMWCalendar: UIScrollViewDelegate {

    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
          switch targetContentOffset.pointee.x {
          case 0:
              scrollDirection = .left
          case self.frame.width * CGFloat(1):
              scrollDirection = .none
          case self.frame.width * CGFloat(2):
              scrollDirection = .right
          default:
              break
          }
      }

      func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
          switch scrollDirection {
          case .left:
              self.currentMonth = self.currentMonth.previousMonth
          case .none:
              break
          case .right:
              self.currentMonth = self.currentMonth.nextMonth
          }
      }
}

extension Date {
    var previousMonth: Date {
        Calendar.current.date(byAdding: .month, value: -1, to: self) ?? Date()
    }

    var nextMonth: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: self) ?? Date()
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var dayNumber: Int {
        Calendar.current.component(.day, from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var firstWeekDayCount: Int {
        return 8 - self.firstDayOfTheMonth.weekday
    }

    var numberOfDays: Int {
        let days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        return self.month == 2 ? self.year.isMultiple(of: 4) ? 29 : 28 : days[self.month - 1]
    }

    var firstDayOfTheMonth: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: self)
        ) ?? Date()
    }

    var scaledDate: Date {
        let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) ?? self
        print(date)
        return date
    }
}
