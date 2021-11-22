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

class LandmarkCartViewController: UIViewController,
                                  Instantiable,
                                  TravelUpdatable,
                                  MapAvailable,
                                  OMWSegmentedControlDelegate {

//    static let badgeElementKind = "badge-element-kind"

    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var segmentedControlView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var collectionView: UICollectionView!

    private(set) var viewModel: LandmarkCartViewModel?
    private var diffableDataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []

    enum Section: CaseIterable { case main }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()
        self.mapView.delegate = self
        self.configureMapView(with: self.mapView)
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = configureCompositionalLayout()
        self.diffableDataSource = configureDiffableDataSource()
        self.configureCancellable()
        self.configureSegmentedControl()
        self.configureDescriptionLable()
    }

    func bind(viewModel: LandmarkCartViewModel) {
        self.viewModel = viewModel
    }

    func didUpdateTravel(to travel: Travel) {
        self.viewModel?.didUpdateTravel(to: travel)
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

    private func configureSegmentedControl() {
        let segmentedControl = OMWSegmentedControl(
            frame: CGRect(origin: .zero, size: self.segmentedControlView.frame.size),
            buttonTitles: ["카드", "지도"]
        )
        self.segmentedControlView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.centerXAnchor.constraint(
                equalTo: segmentedControlView.centerXAnchor
            ),
            segmentedControl.centerYAnchor.constraint(
                equalTo: segmentedControlView.centerYAnchor
            ),
            segmentedControl.widthAnchor.constraint(
                equalTo: segmentedControlView.widthAnchor,
                multiplier: 0.6
            ),
            segmentedControl.heightAnchor.constraint(
                equalTo: segmentedControlView.heightAnchor
            )
        ])
        segmentedControl.delegate = self
    }

    private func configureDescriptionLable() {
        if self.viewModel?.superVC == .reserved {
            self.descriptionLabel.isHidden = true
        }
    }

    private func configureCancellable() {
        self.viewModel?.travelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travel in
                var snapshot = NSDiffableDataSourceSnapshot<
                    LandmarkCartViewController.Section, Landmark
                >()
                snapshot.appendSections([.main])
                let snapshotItem = [Landmark()] + travel.landmarks.reversed()
                snapshot.appendItems(snapshotItem, toSection: .main)
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)

                guard let mapView = self?.mapView else { return }
                let annotations = travel.landmarks.map({ LandmarkAnnotation(landmark: $0) })
                self?.drawLandmarkAnnotations(mapView: mapView, annotations: annotations)
                self?.moveRegion(mapView: mapView, annotations: annotations, animated: true)
            }
            .store(in: &cancellables)
    }
    private func configureCompositionalLayout() -> UICollectionViewLayout {
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

    private func presentAlert(index: Int) {
        guard let landmark = self.viewModel?.findLandmark(at: index) else { return }
        let alert = UIAlertController(title: "관광 명소 삭제",
                                      message: "\(landmark.title ?? "관광지")을(를) 정말 삭제하실건가요?",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            guard let upperVC = self?.navigationController?
                    .viewControllers
                    .last as? LandmarkDeletable & UIViewController,
                  let viewModel = self?.viewModel
            else { return }
            upperVC.didDeleteLandmark(at: viewModel.didDeleteLandmark(at: index))
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true)
    }

    func change(to index: Int) {
        switch index {
        case 0:
            self.scrollView.contentOffset.x = 0
        case 1:
            self.scrollView.contentOffset.x = self.view.frame.maxX
        default: break
        }
    }
}

// MARK: - extension LandmarkCartViewController for UICollectionViewDelegate

extension LandmarkCartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // PlusCell 일 경우
            self.viewModel?.didTouchPlusButton()
        } else {
            guard let viewModel = self.viewModel else { return }
            self.presentAlert(index: viewModel.travel.landmarks.count - indexPath.item)
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
