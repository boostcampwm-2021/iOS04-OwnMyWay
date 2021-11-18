//
//  OutdatedTravelViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import UIKit

class OutdatedTravelViewController: UIViewController, Instantiable,
                                    TravelEditableViewController,
                                    RecordUpdatable {

    @IBOutlet private weak var finishButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var collectionView: UICollectionView!
    private var viewModel: OutdatedTravelViewModel?
    private var diffableDataSource: OngoingTravelDataSource?
    private var cancellables: Set<AnyCancellable> = []
    private let mapDummy = Record.dummy()

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

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    func bind(viewModel: OutdatedTravelViewModel) {
        self.viewModel = viewModel
    }

    func didUpdateTravel(to travel: Travel) {
        self.viewModel?.didUpdateTravel(to: travel)
    }

    func didUpdateRecord(record: Record) {
        self.viewModel?.didUpdateRecord(record: record)
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.finishButtonHeightConstraint.constant = 60 + bottomPadding
    }

    private func configureNavigation() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(self.didTouchSettingButton)
        )
    }

    private func presentAlert() {
        let alert = UIAlertController(
            title: "여행 삭제",
            message: "정말로 삭제하실건가요?\n 삭제된 여행은 되돌릴 수 없어요",
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.viewModel?.didDeleteTravel()
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

    @objc func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.presentAlert()
        }
        let editAction = UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            self?.viewModel?.didTouchEditButton()
        }
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }

    @IBAction func didTouchAddRecordButton(_ sender: Any) {
        self.viewModel?.didTouchAddRecordButton()
    }
}

// MARK: - extension OutdatedTravelViewController for UICollectionViewDelegate

extension OutdatedTravelViewController: UICollectionViewDelegate {
    private func configureNibs() {
        self.collectionView.register(
            UINib(nibName: OutdatedMapCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: OutdatedMapCell.identifier
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
            guard let self = self else { return }

            self.navigationItem.title = travel.title

            if let mapCell = self.collectionView.cellForItem(
                at: IndexPath(item: 0, section: 0)
            ) as? OutdatedMapCell {
                mapCell.configure(with: travel)
            }

            var snapshot = NSDiffableDataSourceSnapshot<String, Record>()
            let recordListList = travel.classifyRecords()
            snapshot.appendSections(["map"])
            snapshot.appendItems([self.mapDummy], toSection: "map")
            recordListList.forEach { recordList in
                guard let date = recordList.first?.date
                else { return }
                snapshot.appendSections([date.toKorean()])
                snapshot.appendItems(recordList, toSection: date.toKorean())
            }
            self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
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
        ) { [weak self] collectionView, indexPath, item in
            guard let self = self else { return UICollectionViewCell() }

            switch indexPath.section {
            case 0:
                guard let travel = self.viewModel?.travel,
                      let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: OutdatedMapCell.identifier, for: indexPath
                ) as? OutdatedMapCell
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

            guard let title = self?.diffableDataSource?.snapshot()
                    .sectionIdentifiers[indexPath.section]
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
