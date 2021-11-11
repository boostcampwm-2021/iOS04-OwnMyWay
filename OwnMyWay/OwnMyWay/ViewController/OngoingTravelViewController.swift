//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
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

    func bind(viewModel: OngoingTravelViewModel) {
        self.viewModel = viewModel
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

            snapshot.appendSections(["2021년 11월 27일"])
            snapshot.appendItems([Record(uuid: UUID(), content: "test1", date: Date(), latitude: 10, longitude: 10, photoURL: nil), Record(uuid: UUID(), content: "test2", date: Date(), latitude: 10, longitude: 10, photoURL: nil)], toSection: "2021년 11월 27일")

            snapshot.appendSections(["2021년 11월 28일"])
            snapshot.appendItems([Record(uuid: UUID(), content: "test3", date: Date(), latitude: 10, longitude: 10, photoURL: nil), Record(uuid: UUID(), content: "test4", date: Date(), latitude: 10, longitude: 10, photoURL: nil)], toSection: "2021년 11월 28일")

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
                cell.configure(with: travel)
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
        guard let record = self.diffableDataSource?.itemIdentifier(for: indexPath)
        else { return }

        self.viewModel?.didTouchRecordCell(at: record)

    }
}
