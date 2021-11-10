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
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0))
            let item = NSCollectionLayoutItem(layoutSize: size)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
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
        return dataSource
    }
}
