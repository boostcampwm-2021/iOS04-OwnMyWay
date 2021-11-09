//
//  ViewController.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/01.
//

import Combine
import UIKit

typealias HomeDataSource = UICollectionViewDiffableDataSource <Travel.Section, Travel>

class HomeViewController: UIViewController, Instantiable, TravelFetchable {

    @IBOutlet private weak var travelCollectionView: UICollectionView!

    private var viewModel: HomeViewModel?
    private var diffableDataSource: HomeDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()
        self.configureTravelCollectionView()
        self.configureCancellable()
        self.viewModel?.viewDidLoad()
    }

    func bind(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    private func configureNibs() {
        self.travelCollectionView.register(
            UINib(nibName: TravelCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: TravelCardCell.identifier
        )
        self.travelCollectionView.register(
            UINib(nibName: PlusCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PlusCell.identifier
        )
        self.travelCollectionView.register(
            UINib(nibName: TravelSectionHeader.identifier, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TravelSectionHeader.identifier
        )
    }

    private func configureTravelCollectionView() {
        self.travelCollectionView.delegate = self
        self.travelCollectionView.collectionViewLayout = configureCompositionalLayout()
        self.diffableDataSource = configureDiffableDataSource()
    }

    private func configureCancellable() {
        viewModel?.reservedTravelPublisher.sink { [weak self] travels in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Travel>()
            let snapshotItem = travels
            snapshot.append(snapshotItem)
            self?.diffableDataSource?.apply(
                snapshot,
                to: Travel.Section.reserved,
                animatingDifferences: true
            )
        }.store(in: &cancellables)

        viewModel?.ongoingTravelPublisher.sink { [weak self] travels in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Travel>()
            let snapshotItem = travels
            snapshot.append(snapshotItem)
            self?.diffableDataSource?.apply(
                snapshot,
                to: Travel.Section.ongoing,
                animatingDifferences: true
            )
        }.store(in: &cancellables)

        viewModel?.outdatedTravelPublisher.sink { [weak self] travels in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Travel>()
            let snapshotItem = travels
            snapshot.append(snapshotItem)
            self?.diffableDataSource?.apply(
                snapshot,
                to: Travel.Section.outdated,
                animatingDifferences: true
            )
        }.store(in: &cancellables)
    }

    func fetchTravel() {
        self.viewModel?.viewDidLoad()
    }

    private func configureCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.8)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 5, leading: 5, bottom: 5, trailing: 5
        )

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(300), heightDimension: .absolute(240)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10, leading: 10, bottom: 10, trailing: 10
        )
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60)
        )
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [headerElement]
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func configureDiffableDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(
            collectionView: self.travelCollectionView
        ) { collectionView, indexPath, item in

                switch (indexPath.section, item.flag) {
                case (Travel.Section.reserved.index, -1):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PlusCell.identifier,
                        for: indexPath) as? PlusCell
                    else { return UICollectionViewCell() }
                    cell.configure()
                    return cell
                default:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: TravelCardCell.identifier,
                        for: indexPath) as? TravelCardCell
                    else { return UICollectionViewCell() }
                    cell.configure(with: item)
                    return cell
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

extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let travel = self.diffableDataSource?.itemIdentifier(for: indexPath)
        else { return }
        if travel.flag == -1 {
            self.viewModel?.didTouchCreateButton()
            return
        }
        switch indexPath.section {
        case Travel.Section.reserved.index:
            self.viewModel?.didTouchReservedTravel(at: indexPath.item)
        case Travel.Section.ongoing.index:
            return
        case Travel.Section.outdated.index:
            return
        default:
            return
        }

    }

}
