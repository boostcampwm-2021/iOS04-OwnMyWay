//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import Combine
import CoreLocation
import MapKit
import UIKit

typealias DataSource = UICollectionViewDiffableDataSource <LandmarkCartViewController.Section,
                                                           Landmark>

class LandmarkCartViewController: UIViewController, Instantiable, MapAvailable {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionView: UICollectionView!

    private(set) var viewModel: LandmarkCartViewModel?
    private var diffableDataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []
    private let locationManager: CLLocationManager = CLLocationManager()

    enum Section: CaseIterable { case main }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()

        self.mapView.delegate = self
        self.configureMapView(with: self.mapView)

        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()

        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = configureCompositionalLayout()
        self.diffableDataSource = configureDiffableDataSource()
        self.configureCancellable()
    }

    func bind(viewModel: LandmarkCartViewModel) {
        self.viewModel = viewModel
    }

    private func configureNibs() {
        self.collectionView.register(
            UINib(nibName: LandmarkCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: LandmarkCardCell.identifier
        )
        self.collectionView.register(
            UINib(nibName: PlusCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PlusCell.identifier
        )
    }

    private func configureCancellable() {
        self.viewModel?.travelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travel in
                var snapshot = NSDiffableDataSourceSectionSnapshot<Landmark>()
                let snapshotItem = [Landmark()] + travel.landmarks.reversed()
                snapshot.append(snapshotItem)
                self?.diffableDataSource?.apply(snapshot, to: .main, animatingDifferences: true)

                guard let mapView = self?.mapView else { return }
                let annotations = travel.landmarks.map({ LandmarkAnnotation(landmark: $0) })
                self?.drawLandmarkAnnotations(mapView: mapView, annotations: annotations)
                self?.moveRegion(mapView: mapView, annotations: annotations, animated: true)
            }
            .store(in: &cancellables)
    }

    private func configureCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 5, leading: 5, bottom: 5, trailing: 5
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(180), heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )

        return UICollectionViewCompositionalLayout(section: section)
    }

    private func configureDiffableDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: self.collectionView
        ) { collectionView, indexPath, item in
                switch indexPath.item {
                case 0: // plusCell
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PlusCell.identifier,
                        for: indexPath
                    ) as? PlusCell
                    else { return UICollectionViewCell() }
                    cell.configure()
                    return cell
                default:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: LandmarkCardCell.identifier,
                        for: indexPath
                    ) as? LandmarkCardCell
                    else { return UICollectionViewCell() }
                    cell.configure(with: item)
                    return cell
                }
        }
        return dataSource
    }
}

// MARK: - extension LandmarkCartViewController for UICollectionViewDelegate

extension LandmarkCartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // PlusCell 일 경우
            self.viewModel?.didTouchPlusButton()
        }
    }
}

// MARK: - extension LandmarkCartViewController for MapView

extension LandmarkCartViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is LandmarkAnnotation:
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: LandmarkAnnotationView.identifier,
                for: annotation
            ) as? LandmarkAnnotationView
            annotationView?.annotation = annotation
            return annotationView
        default:
            return nil
        }
    }
}

extension LandmarkCartViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard self.viewModel?.travel.landmarks.isEmpty == true else { return }
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.mapView.setRegion(
            MKCoordinateRegion(
                center: locValue,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ),
            animated: false
        )
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
}
