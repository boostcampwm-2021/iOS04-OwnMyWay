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

class LandmarkCartViewController: UIViewController, Instantiable {

    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionView: UICollectionView!
    // usecase, viewModel 상위에서 주입
    private var viewModel: LandmarkCartViewModelType?
    private var diffableDataSource: DataSource?
    private var cancellable: AnyCancellable?

    enum Section: CaseIterable { case main }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        self.initializeMapView()
        self.collectionView.collectionViewLayout = createCompositionalLayout()
        // 아래는 상위에서 주입 받을 시 삭제해야하는 코드입니다.
        let usecase = DefaultLandmarkCartUsecase(travelRepository: CoreDataTravelRepository())
        self.viewModel = LandmarkCartViewModel(landmarkCartUsecase: usecase)
        // 여기까지
        self.diffableDataSource = createMakeDiffableDataSource()
        self.configureCancellable()
    }

    private func registerNib() {
        self.collectionView.register(UINib(nibName: LandmarkCardCell.identifier, bundle: nil),
                                     forCellWithReuseIdentifier: LandmarkCardCell.identifier)
        self.collectionView.register(UINib(nibName: PlusCell.identifier, bundle: nil),
                                     forCellWithReuseIdentifier: PlusCell.identifier)
    }

    private func configureCancellable() {
        guard let viewModel = viewModel else { return }
        self.cancellable = viewModel.landmarksPublisher.sink { [weak self] landmarks in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Landmark>()
            let snapshotItem = landmarks + [Landmark()]
            snapshot.append(snapshotItem)
            self?.diffableDataSource?.apply(snapshot, to: .main, animatingDifferences: false)

            DispatchQueue.main.async { self?.drawMap(landmarks: landmarks) }
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                               heightDimension: .estimated(50))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                        leading: 10,
                                                        bottom: 10,
                                                        trailing: 10)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func createMakeDiffableDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: self.collectionView) { collectionView, indexPath, item in
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }

                switch indexPath.item {
                case viewModel.landmarks.count:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PlusCell.identifier,
                        for: indexPath) as? PlusCell
                    else { return UICollectionViewCell() }
                    cell.bind()
                    return cell
                default:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: LandmarkCardCell.identifier,
                        for: indexPath) as? LandmarkCardCell
                    else { return UICollectionViewCell() }
                    cell.configure(landmark: item)
                    return cell
                }
        }
        return dataSource
    }
}

// MARK: - extension LandmarkCartViewController for MapView

extension LandmarkCartViewController {
    private func initializeMapView() {
        self.mapView.delegate = self
        self.mapView.register(
            LandmarkAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: LandmarkAnnotationView.identifier
        )
        self.mapView.setRegion(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 37.24800,
                    longitude: 127.07845
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            ),
            animated: false
        )
    }

    private func drawMap(landmarks: [Landmark]) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        let annotations = landmarks.map { LandmarkAnnotation(landmark: $0) }
        self.mapView.addAnnotations(annotations)
        if !landmarks.isEmpty {
            self.mapView.setRegion(changeRegion(landmarks: landmarks), animated: true)
        }
    }

    private func changeRegion(landmarks: [Landmark]) -> MKCoordinateRegion {
        var minLatitude: Double = 1000
        var maxLatitude: Double = -1000
        var minLongitude: Double = 1000
        var maxLongitude: Double = -1000

        landmarks.forEach { landmark in
            minLatitude = min(minLatitude, landmark.latitude ?? 0)
            maxLatitude = max(maxLatitude, landmark.latitude ?? 0)
            minLongitude = min(minLongitude, landmark.longitude ?? 0)
            maxLongitude = max(maxLongitude, landmark.longitude ?? 0)
        }

        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = max(center.latitude - minLatitude, center.longitude - minLongitude)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )
    }
}

extension LandmarkCartViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is LandmarkAnnotation:
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: LandmarkAnnotationView.identifier,
                for: annotation
            ) as? LandmarkAnnotationView
            annotationView?.configure(annotation: annotation)
            return annotationView
        default:
            return nil
        }
    }
}
