//
//  SearchLandmarkViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/04.
//

import Combine
import UIKit

final class SearchLandmarkViewController: UIViewController, Instantiable {

    // MARK: IBOutlet
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: Internal Variable
    private var viewModel: SearchLandmarkViewModel?
    private var diffableDataSource: DataSource?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Override Function
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()
        self.collectionView.collectionViewLayout = configureCompositionalLayout()
        self.diffableDataSource = configureDiffableDataSource()
        self.searchBar.delegate = self
        self.collectionView.delegate = self
        self.configureCancellable()
    }

    // MARK: Internal Function
    func bind(viewModel: SearchLandmarkViewModel) {
        self.viewModel = viewModel
    }

    private func configureNibs() {
        self.collectionView.register(
            UINib(nibName: LandmarkCardCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: LandmarkCardCell.identifier
        )
    }

    private func configureCancellable() {
        self.viewModel?.landmarksPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                var snapshot = NSDiffableDataSourceSnapshot<
                    LandmarkCartViewController.Section, Landmark
                >()
                snapshot.appendSections([.main])
                snapshot.appendItems(items, toSection: .main)
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)

        self.viewModel?.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] optionalError in
                guard let error = optionalError else { return }
                ErrorManager.showToast(with: error, to: self)
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

            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: LandmarkCardCell.identifier, for: indexPath
            ) as? LandmarkCardCell
            else { return UICollectionViewCell() }

            cell.configure(with: item)
            return cell
        }
        return dataSource
    }
}

// MARK: - SearchLandmarkViewController for SerachBarDelegate
extension SearchLandmarkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel?.didChangeSearchText(with: searchText)
    }
}

// MARK: - SearchLandmarkViewController for UICollectionViewDelegate
extension SearchLandmarkViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel?.didTouchLandmarkCard(at: indexPath.item)
    }
}
