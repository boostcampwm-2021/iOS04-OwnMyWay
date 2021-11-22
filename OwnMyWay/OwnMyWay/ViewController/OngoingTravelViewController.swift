//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import MapKit
import UIKit

typealias RecordDataSource = UICollectionViewDiffableDataSource <String, Record>

class OngoingTravelViewController: UIViewController, Instantiable, TravelEditable, TravelUpdatable {

    @IBOutlet private weak var finishButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var recordCollectionView: UICollectionView!
    @IBOutlet private weak var segmentedControl: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var trackingButton: UIButton!
    @IBOutlet private weak var userLocationButton: UIButton!
    @IBOutlet private weak var landmarkCollectionView: UICollectionView!

    private var viewModel: OngoingTravelViewModel?
    private var recordDataSource: RecordDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigation()
        self.configureNibs()
        self.configureCollectionViews()
        self.configureCancellable()
        self.configureButton()
        self.configureSegment()
        LocationManager.shared.currentTravel(to: self.viewModel?.travel)
        LocationManager.shared.requestWhenInUseAuthorization()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocationManager.shared.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LocationManager.shared.delegate = LocationManager.shared
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    func bind(viewModel: OngoingTravelViewModel) {
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

    private func configureNavigation() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(self.didTouchSettingButton)
        )
    }

    private func configureButton() {
        if LocationManager.shared.fetchAuthorizationStatus() == .authorizedAlways {
            switch LocationManager.shared.isUpdatingLocation {
            case true:
                self.trackingButton.isSelected = true
            case false:
                self.trackingButton.isSelected = false
            }
        }
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
            title: "여행 삭제 실패",
            message: "진행중인 여행은 삭제할 수 없어요\n여행을 먼저 종료하고 삭제해주세요",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "확인", style: .default)
        alert.addAction(action)
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

    @IBAction func didTouchAddRecordButton(_ sender: UIButton) {
        self.viewModel?.didTouchAddRecordButton()
    }

    @IBAction func didTouchFinishButton(_ sender: UIButton) {
        self.viewModel?.didTouchFinishButton()
    }

    @IBAction func didTouchTrackingButton(_ sender: Any) {
        if LocationManager.shared.fetchAuthorizationStatus() == .authorizedAlways {
            self.trackingButton.isSelected.toggle()
            switch LocationManager.shared.isUpdatingLocation {
            case true:
                LocationManager.shared.stopUpdatingLocation()
            case false:
                self.mapView.setUserTrackingMode(.follow, animated: true)
                LocationManager.shared.startUpdatingLocation()
            }

        } else {
            let alert = UIAlertController(
                title: "권한 설정이 필요합니다.",
                message: "Setting -> OwnMyWay -> 위치 -> 항상 허용",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "이동", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }

    @IBAction func didTouchUserLocationButton(_ sender: Any) {
        self.mapView.setUserTrackingMode(.follow, animated: true)
    }
}

extension OngoingTravelViewController: UICollectionViewDelegate {

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
    }

    private func configureCollectionViews() {
        self.recordCollectionView.delegate = self
        self.recordCollectionView.collectionViewLayout = configureRecordCompositionalLayout()
        self.recordDataSource = configureRecordDiffableDataSource()
    }

    private func configureCancellable() {
        viewModel?.travelPublisher.sink { [weak self] travel in
            guard let self = self else { return }

            self.navigationItem.title = travel.title
            (self.mapView as? OMWMapView)?.configure(with: travel)

            var snapshot = NSDiffableDataSourceSnapshot<String, Record>()
            let recordListList = travel.classifyRecords()
            recordListList.forEach { recordList in
                guard let date = recordList.first?.date
                else { return }
                snapshot.appendSections([date.toKorean()])
                snapshot.appendItems(recordList, toSection: date.toKorean())
            }
            self.recordDataSource?.apply(snapshot, animatingDifferences: true)
        }.store(in: &cancellables)
    }

    private func configureRecordCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let record = self.recordDataSource?.itemIdentifier(for: indexPath)
        else { return }
        self.viewModel?.didTouchRecordCell(at: record)
    }
}

// MARK: - extension OngoingTravelViewController for CLLocationManagerDelegate

extension OngoingTravelViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        guard let latitude = lastLocation?.coordinate.latitude,
              let longitude = lastLocation?.coordinate.longitude
        else { return }
        self.viewModel?.didUpdateCoordinate(latitude: latitude, longitude: longitude)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {

        switch manager.fetchAuthorizationStatus() {
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        default:
            break
        }

    }
}

// MARK: - extension OngoingTravelViewController for RecordUpdatable

extension OngoingTravelViewController: RecordUpdatable {

    func didUpdateRecord(record: Record) {
        self.viewModel?.didUpdateRecord(record: record)
    }
}

// MARK: - extension OngoingTravelViewController for OMWSegmentedControlDelegate

extension OngoingTravelViewController: OMWSegmentedControlDelegate {

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
