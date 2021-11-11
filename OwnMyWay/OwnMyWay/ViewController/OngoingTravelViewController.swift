//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import MapKit
import UIKit

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
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
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

    func bind(viewModel: OngoingTravelViewModel) {
        self.viewModel = viewModel
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
            self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
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
        ) { collectionView, indexPath, item in
            switch indexPath.section {
            case 0:
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MapCell.identifier, for: indexPath
                ) as? MapCell,
                      let travel = self.viewModel?.travel
                else { return UICollectionViewCell() }
                cell.configure(with: travel, delegate: self)
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

            guard let title = self?.diffableDataSource?.sectionIdentifier(for: indexPath.section)
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
}
