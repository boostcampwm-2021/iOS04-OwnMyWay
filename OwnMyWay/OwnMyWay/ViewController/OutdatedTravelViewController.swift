//
//  OutdatedTravelViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import MapKit
import UIKit

class OutdatedTravelViewController: UIViewController, Instantiable,
                                        TravelUpdatable, TravelEditable {

    @IBOutlet private weak var finishButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var segmentedControl: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var recordCollectionView: UICollectionView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var landmarkCollectionView: UICollectionView!
    @IBOutlet private weak var periodLabel: UILabel!
    @IBOutlet private weak var emptyRecordLabel: UILabel!
    @IBOutlet private weak var emptyLandmarkLabel: UILabel!

    private var viewModel: OutdatedTravelViewModel?
    private var recordDataSource: RecordDataSource?
    private var landmarkDataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()
        self.configureCollectionViews()
        self.configureCancellable()
        self.configureSegment()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationController()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    func bind(viewModel: OutdatedTravelViewModel) {
        self.viewModel = viewModel
    }

    func didEditTravel(to travel: Travel) {
        self.viewModel?.didUpdateTravel(to: travel)
    }

    func didUpdateTravel(to travel: Travel) {
        self.viewModel?.didUpdateTravel(to: travel)
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.finishButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureNavigationController() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(self.didTouchSettingButton)
        )
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = self.viewModel?.travel.title
    }

    private func configureSegment() {
        let omwSegmentedControl = OMWSegmentedControl(
            frame: CGRect(origin: .zero, size: self.segmentedControl.frame.size),
            buttonTitles: ["게시물", "지도", "관광명소"]
        )
        omwSegmentedControl.delegate = self
        self.segmentedControl.addSubview(omwSegmentedControl)
        self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        self.segmentedControl.topAnchor.constraint(
            equalTo: self.segmentedControl.topAnchor
        ).isActive = true
        self.segmentedControl.leadingAnchor.constraint(
            equalTo: self.segmentedControl.leadingAnchor
        ).isActive = true
        self.segmentedControl.trailingAnchor.constraint(
            equalTo: self.segmentedControl.trailingAnchor
        ).isActive = true
        self.segmentedControl.bottomAnchor.constraint(
            equalTo: self.segmentedControl.bottomAnchor
        ).isActive = true
    }

    private func presentAlert() {
        let alert = UIAlertController(
            title: "여행 삭제",
            message: "정말로 삭제하실건가요?\n 삭제된 여행은 되돌릴 수 없어요",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.viewModel?.didDeleteTravel()
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

    @objc func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.presentAlert()
        }
        let editAction = UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            self?.viewModel?.didTouchEditButton()
        }
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }

    @IBAction func didTouchAddRecordButton(_ sender: Any) {
        self.viewModel?.didTouchAddRecordButton()
    }
}

// MARK: - extension OutdatedTravelViewController for UICollectionViewDelegate

extension OutdatedTravelViewController: UICollectionViewDelegate {

    private func configureNibs() {
        self.recordCollectionView.register(
            UINib(nibName: RecordCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: RecordCardCell.identifier
        )
        self.recordCollectionView.register(
            UINib(nibName: DateHeaderView.identifier, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DateHeaderView.identifier
        )
        self.landmarkCollectionView.register(
            UINib(nibName: LandmarkCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: LandmarkCardCell.identifier
        )
    }

    private func configureCollectionViews() {
        self.recordCollectionView.delegate = self
        self.recordCollectionView.collectionViewLayout = configureRecordCompositionalLayout()
        self.recordDataSource = configureRecordDiffableDataSource()
        self.landmarkCollectionView.collectionViewLayout = configureLandmarkCompositionalLayout()
        self.landmarkDataSource = configureLandmarkDiffableDataSource()
    }

    private func configureCancellable() {
        viewModel?.travelPublisher.sink { [weak self] travel in
            guard let self = self,
                  let startDate = travel.startDate?.dotLocalize(),
                  let endDate = travel.endDate?.dotLocalize()
            else { return }

            self.emptyRecordLabel.isHidden = !travel.records.isEmpty
            self.emptyLandmarkLabel.isHidden = !travel.landmarks.isEmpty
            self.navigationItem.title = travel.title
            self.periodLabel.text = startDate + " ~ " + endDate
            (self.mapView as? OMWMapView)?.configure(with: travel, isMovingCamera: true)

            var recordSnapshot = NSDiffableDataSourceSnapshot<String, Record>()
            let recordListList = travel.classifyRecords()
            recordListList.forEach { recordList in
                guard let date = recordList.first?.date
                else { return }
                recordSnapshot.appendSections([date.toKorean()])
                recordSnapshot.appendItems(recordList, toSection: date.toKorean())
            }
            self.recordDataSource?.apply(recordSnapshot, animatingDifferences: true)

            var landmarkSnapshot = NSDiffableDataSourceSnapshot<
                LandmarkCartViewController.Section, Landmark
            >()
            landmarkSnapshot.appendSections([.main])
            landmarkSnapshot.appendItems(travel.landmarks, toSection: .main)
            self.landmarkDataSource?.apply(landmarkSnapshot, animatingDifferences: true)
        }.store(in: &cancellables)

        self.viewModel?.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] optionalError in
                guard let error = optionalError else { return }
                ErrorManager.showAlert(with: error, to: self)
            }
            .store(in: &self.cancellables)
    }

    private func configureRecordCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(
                top: 0, leading: 30, bottom: 0, trailing: 30
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 30
            if index + 1 == self.recordDataSource?.snapshot().numberOfSections {
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 0, bottom: 60, trailing: 0
                )
            }

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)
            )
            let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [headerElement]
            return section
        }
        return layout
    }

    private func configureRecordDiffableDataSource() -> RecordDataSource {
        let dataSource = RecordDataSource(
            collectionView: self.recordCollectionView
        ) { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: RecordCardCell.identifier, for: indexPath
            ) as? RecordCardCell
            else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DateHeaderView.identifier,
                for: indexPath
            ) as? DateHeaderView
            else { return UICollectionReusableView() }

            guard let title = self?.recordDataSource?.snapshot()
                    .sectionIdentifiers[indexPath.section]
            else { return UICollectionReusableView() }
            sectionHeader.configure(with: title)
            return sectionHeader
        }
        return dataSource
    }

    private func configureLandmarkCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.7)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 5, leading: 5, bottom: 5, trailing: 5
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.7)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func configureLandmarkDiffableDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: self.landmarkCollectionView
        ) { collectionView, indexPath, item in

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LandmarkCardCell.identifier, for: indexPath
            ) as? LandmarkCardCell
            else { return UICollectionViewCell() }
            cell.configure(with: item)
            return cell
        }
        return dataSource
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let record = self.recordDataSource?.itemIdentifier(for: indexPath)
        else { return }
        self.viewModel?.didTouchRecordCell(at: record)
    }
}

// MARK: - extension OngoingTravelViewController for RecordUpdatable

extension OutdatedTravelViewController: RecordUpdatable {
    func didUpdateRecord(record: Record) {
        self.viewModel?.didUpdateRecord(record: record)
    }
}

// MARK: - extension OngoingTravelViewController for OMWSegmentedControlDelegate

extension OutdatedTravelViewController: OMWSegmentedControlDelegate {
    func change(to index: Int) {
        switch index {
        case 0:
            self.scrollView.scrollRectToVisible(
                self.recordCollectionView.frame, animated: true
            )
        case 1:
            self.scrollView.scrollRectToVisible(
                self.mapView.frame, animated: true
            )
        case 2:
            self.scrollView.scrollRectToVisible(
                self.landmarkCollectionView.frame, animated: true
            )
        default:
            break
        }
    }
}
