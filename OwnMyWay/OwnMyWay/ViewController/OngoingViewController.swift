//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import UIKit

typealias OngoingDataSource = UICollectionViewDiffableDataSource <Int, Record>

class OngoingViewController: UIViewController, Instantiable {
    @IBOutlet private weak var finishButtonHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: OngoingViewModel?
    private var diffableDataSource: OngoingDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
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

    func bind(viewModel: OngoingViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func didTouchAddRecordButton(_ sender: UIButton) {
        self.viewModel?.didTouchAddRecordButton()
    }

    @IBAction func didTouchFinishButton(_ sender: UIButton) {
        self.viewModel?.didTouchFinishButton()
    }

}

extension OngoingViewController: UICollectionViewDelegate {

    private func configureNibs() {
        self.collectionView.register(
            UINib(nibName: MapCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: MapCell.identifier
        )
    }

    private func configureTravelCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.collectionViewLayout = configureCompositionalLayout()
        self.diffableDataSource = configureDiffableDataSource()
    }

    private func configureCancellable() {
        viewModel?.travelPublisher.sink { [weak self] travel in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Record>()
            let snapshotItem = [Record.dummy()] + travel.records
            snapshot.append(snapshotItem)
            self?.diffableDataSource?.apply(snapshot, to: 0, animatingDifferences: true)
        }.store(in: &cancellables)
    }

    private func configureCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            let size = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(10)
            )
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            if index != 0 {
                group.contentInsets = NSDirectionalEdgeInsets(
                    top: 10, leading: 20, bottom: 10, trailing: 20
                )
            }
            let section = NSCollectionLayoutSection(group: group)
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)
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

    private func configureDiffableDataSource() -> OngoingDataSource {
        let dataSource = OngoingDataSource(
            collectionView: self.collectionView
        ) { collectionView, indexPath, _ in
            switch indexPath.section {
            case 0: // MapView
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MapCell.identifier, for: indexPath
                ) as? MapCell,
                      let travel = self.viewModel?.travel
                else { return UICollectionViewCell() }
                cell.configure(with: travel)
                return cell

            default:
                return UICollectionViewCell()
            }
        }
        dataSource.supplementaryViewProvider = { (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TravelSectionHeader.identifier,
                for: indexPath
            ) as? TravelSectionHeader
            else { return UICollectionReusableView() }
            let title = ["예정된 여행", "진행중인 여행", "지난 여행"]
            sectionHeader.configure(sectionTitle: title[indexPath.section])
            return sectionHeader
        }
        return dataSource
    }
}
