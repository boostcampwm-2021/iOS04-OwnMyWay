//
//  SearchLandmarkViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/04.
//

import Combine
import UIKit

class SearchLandmarkViewController: UIViewController, Instantiable {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!

    // usecase, viewModel 상위에서 주입
    private var viewModel: SearchLandmarkViewModelType?
    private var diffableDataSource: DataSource?
    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNib()
        self.collectionView.collectionViewLayout = createCompositionalLayout()
        self.diffableDataSource = createMakeDiffableDataSource()
        self.searchBar.delegate = self
        self.configureCancellable()
    }

    func bind(viewModel: SearchLandmarkViewModelType) {
        self.viewModel = viewModel
    }

    private func registerNib() {
        self.collectionView.register(UINib(nibName: LandmarkCardCell.identifier, bundle: nil),
                                     forCellWithReuseIdentifier: LandmarkCardCell.identifier)
    }

    private func configureCancellable() {
        self.cancellable = self.viewModel?.landmarksPublisher.sink { [weak self] items in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Landmark>()
            snapshot.append(items)
            self?.diffableDataSource?.apply(snapshot, to: .main, animatingDifferences: true)
        }
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalWidth(0.7))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                        leading: 10,
                                                        bottom: 10,
                                                        trailing: 10)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    private func createMakeDiffableDataSource() -> DataSource {
        let dataSource = DataSource(
            collectionView: self.collectionView
        ) { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: LandmarkCardCell.identifier,
                    for: indexPath
                ) as? LandmarkCardCell
                else { return UICollectionViewCell() }
                cell.configure(landmark: item)
                return cell
        }
        return dataSource
    }
}

// MARK: - SearchLandmarkViewController for SerachBarDelegate
extension SearchLandmarkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.viewModel?.searchText = searchText
    }
}
