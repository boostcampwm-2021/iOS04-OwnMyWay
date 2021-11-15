//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import MapKit
import UIKit
import OSLog

typealias OngoingTravelDataSource = UICollectionViewDiffableDataSource <String, Record>

class OngoingTravelViewController: UIViewController, Instantiable {
    @IBOutlet private weak var finishButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: OngoingTravelViewModel?
    private var diffableDataSource: OngoingTravelDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNavigation()
        self.configureNibs()
        self.configureTravelCollectionView()
        self.configureCancellable()
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
    }

    func bind(viewModel: OngoingTravelViewModel) {
        self.viewModel = viewModel
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.finishButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureNavigation() {
        self.navigationItem.title = viewModel?.travel.title

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonAction)
        )
    }

    @objc private func backButtonAction() {
        self.viewModel?.didTouchBackButton()
    }

    @IBAction func didTouchAddRecordButton(_ sender: UIButton) {
        self.viewModel?.didTouchAddRecordButton()
    }

    @IBAction func didTouchFinishButton(_ sender: UIButton) {
        self.viewModel?.didTouchFinishButton()
    }

}

extension OngoingTravelViewController: UICollectionViewDelegate {

    private func configureNibs() {
        self.collectionView.register(
            UINib(nibName: MapCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: MapCell.identifier
        )
        self.collectionView.register(
            UINib(nibName: RecordCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: RecordCardCell.identifier
        )
        self.collectionView.register(
            UINib(nibName: DateHeaderView.identifier, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DateHeaderView.identifier
        )
    }

    private func configureTravelCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = configureCompositionalLayout()
        self.diffableDataSource = configureDiffableDataSource()
    }

    private func configureCancellable() {
        viewModel?.travelPublisher.sink { [weak self] travel in
            guard let self = self else { return }

            if let mapCell = self.collectionView.cellForItem(
                at: IndexPath(item: 0, section: 0)
            ) as? MapCell {
                mapCell.configure(with: travel, mapDelegate: self, buttonDelegate: self)
            }

            var snapshot = NSDiffableDataSourceSnapshot<String, Record>()
            let recordListList = travel.classifyRecords()
            snapshot.appendSections(["map"])
            snapshot.appendItems([Record.dummy()], toSection: "map")
            recordListList.forEach { recordList in
                guard let date = recordList.first?.date
                else { return }
                snapshot.appendSections([date.toKorean()])
                snapshot.appendItems(recordList, toSection: date.toKorean())
            }
            self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
        }.store(in: &cancellables)
    }

    private func configureCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(500)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            if index != 0 {
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 0, leading: 30, bottom: 0, trailing: 30
                )
            }
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 30
            if index != 0 {
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)
                )
                let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [headerElement]
            }
            return section
        }
        return layout
    }

    private func configureDiffableDataSource() -> OngoingTravelDataSource {
        let dataSource = OngoingTravelDataSource(
            collectionView: self.collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }

            switch indexPath.section {
            case 0:
                guard let travel = self.viewModel?.travel,
                      let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MapCell.identifier, for: indexPath
                ) as? MapCell
                else { return UICollectionViewCell() }
                cell.configure(with: travel, mapDelegate: self, buttonDelegate: self)
                return cell

            default:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: RecordCardCell.identifier, for: indexPath
                ) as? RecordCardCell
                else { return UICollectionViewCell() }
                cell.configure(with: item)
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DateHeaderView.identifier,
                for: indexPath
            ) as? DateHeaderView
            else { return UICollectionReusableView() }

            guard let title = self?.diffableDataSource?.snapshot()
                    .sectionIdentifiers[indexPath.section]
            else { return UICollectionReusableView() }

            sectionHeader.configure(with: title)
            return sectionHeader
        }
        return dataSource
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let record = self.diffableDataSource?.itemIdentifier(for: indexPath),
              indexPath.section != 0
        else { return }

        self.viewModel?.didTouchRecordCell(at: record)
    }
}

// MARK: - extension OngoingTravelViewController for MKMapViewDelegate

extension OngoingTravelViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is LandmarkAnnotation:
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: LandmarkAnnotationView.identifier,
                for: annotation
            ) as? LandmarkAnnotationView
            annotationView?.annotation = annotation
            return annotationView
        case is RecordAnnotation:
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: RecordAnnotationView.identifier,
                for: annotation
            ) as? RecordAnnotationView
            annotationView?.annotation = annotation
            return annotationView
        default:
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let polylineRenderer = MKPolylineRenderer(polyline: polyline)
        polylineRenderer.strokeColor = .orange
        polylineRenderer.lineWidth = 5
        polylineRenderer.alpha = 1
        polylineRenderer.lineCap = .round
        return polylineRenderer
    }
}

// MARK: - extension OngoingTravelViewController for ButtonDelegate

extension OngoingTravelViewController: ButtonDelegate {
    func didTouchTrackingButton() {
        if LocationManager.shared.authorizationStatus == .authorizedAlways {
            switch LocationManager.shared.isUpdatingLocation {
            case true: LocationManager.shared.stopUpdatingLocation()
            case false: LocationManager.shared.startUpdatingLocation()
            }

        } else {
            let alert = UIAlertController(
                title: "권한 설정이 필요합니다.",
                message: "Setting -> OnwMyWay App -> 위치 -> 항상 허용",
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
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }
}
