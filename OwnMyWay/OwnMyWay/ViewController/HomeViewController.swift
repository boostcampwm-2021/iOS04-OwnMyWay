//
//  ViewController.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/01.
//

import Combine
import UIKit

typealias HomeDataSource = UICollectionViewDiffableDataSource <Travel.Section, Travel>

final class HomeViewController: UIViewController, Instantiable, TravelFetchable {

    @IBOutlet private weak var travelCollectionView: UICollectionView!
    @IBOutlet private weak var settingButton: UIButton!
    @IBOutlet private weak var createButton: UIButton!
    private var viewModel: HomeViewModel?
    private var diffableDataSource: HomeDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureButton()
        self.configureNibs()
        self.configureTravelCollectionView()
        self.configureDataSource()
        self.configureCancellable()
        self.viewModel?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = ""
    }

    func bind(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }

    func fetchTravel() {
        self.viewModel?.viewDidLoad()
    }

    private func configureButton() {
        let emptyTitle = ""
        self.settingButton.setTitle(emptyTitle, for: .normal)
        self.createButton.setTitle(emptyTitle, for: .normal)
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
        self.travelCollectionView.register(
            UINib(nibName: CommentCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: CommentCell.identifier
        )
        self.travelCollectionView.register(
            UINib(nibName: MessageCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: MessageCell.identifier
        )
    }

    private func configureTravelCollectionView() {
        self.travelCollectionView.delegate = self
        self.travelCollectionView.collectionViewLayout = self.createCompositionalLayout()
        self.diffableDataSource = self.createDiffableDataSource()
    }

    private func configureDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<Travel.Section, Travel>()
        snapshot.appendSections([.dummy, .reserved, .ongoing, .outdated])
        self.diffableDataSource?.apply(snapshot, animatingDifferences: false)
    }

    private func configureCancellable() {
        self.viewModel?.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                guard var snapshot = self?.diffableDataSource?.snapshot() else { return }
                snapshot.deleteSections([.dummy])
                if travels.isEmpty {
                    self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
                    return
                }
                snapshot.insertSections([.dummy], beforeSection: .reserved)
                snapshot.appendItems(travels, toSection: .dummy)
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &self.cancellables)

        self.viewModel?.reservedTravelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                guard var snapshot = self?.diffableDataSource?.snapshot() else { return }
                snapshot.deleteSections([.reserved])
                snapshot.insertSections([.reserved], beforeSection: .ongoing)
                snapshot.appendItems(travels, toSection: .reserved)
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &self.cancellables)

        self.viewModel?.ongoingTravelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                guard var snapshot = self?.diffableDataSource?.snapshot() else { return }
                snapshot.deleteSections([.ongoing])
                snapshot.insertSections([.ongoing], afterSection: .reserved)
                snapshot.appendItems(travels, toSection: .ongoing)
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &self.cancellables)

        self.viewModel?.outdatedTravelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                guard var snapshot = self?.diffableDataSource?.snapshot() else { return }
                snapshot.deleteSections([.outdated])
                snapshot.insertSections([.outdated], afterSection: .ongoing)
                snapshot.appendItems(travels, toSection: .outdated)
                self?.diffableDataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &self.cancellables)

        self.viewModel?.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] optionalError in
                guard let error = optionalError else { return }
                ErrorManager.showToast(with: error, to: self)
            }
            .store(in: &self.cancellables)
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _)
            -> NSCollectionLayoutSection? in
            let sectionLayout = Travel.Section.allCases[sectionIndex]
            switch sectionLayout {
            case .dummy:
                return self.createMessageSection()
            default:
                return self.createLayoutSection()
            }
        }
        layout.register(
            UINib(nibName: HomeBackgroundView.identifier, bundle: nil),
            forDecorationViewOfKind: ElementKind.background
        )

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 30
        layout.configuration = config
        return layout
    }

    private func createMessageSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 30, leading: 0, bottom: 30, trailing: 0
        )
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: ElementKind.background)
        ]
        return section
    }

    private func createLayoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8), heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize, subitems: [item]
        )

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(30)
        )
        let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 25, leading: 20, bottom: 40, trailing: 20
        )
        section.interGroupSpacing = 25
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: ElementKind.background)
        ]
        section.boundarySupplementaryItems = [headerElement]
        return section
    }

    private func createDiffableDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(
            collectionView: self.travelCollectionView
        ) { collectionView, indexPath, item in
            if item.flag == -1 {
                let sections = collectionView.numberOfSections
                if self.isMessageCell(section: indexPath.section, sections: sections) {
                    return self.dequeueMessageCell(in: collectionView, with: indexPath)
                }
                return self.dequeueCommentCell(in: collectionView, with: indexPath)
            }
            return self.dequeueTravelCardCell(in: collectionView, with: indexPath, using: item)
        }
        dataSource.supplementaryViewProvider = configureSupplementaryView(
            collectionView:kind:indexPath:
        )
        return dataSource
    }

    private func isMessageCell(section: Int, sections: Int) -> Bool {
        let allSectionsCount = Travel.Section.allCases.count
        return sections == allSectionsCount && section == 0
    }

    private func dequeueMessageCell(
        in collectionView: UICollectionView, with indexPath: IndexPath
    ) -> MessageCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MessageCell.identifier,
            for: indexPath) as? MessageCell
        else { return MessageCell() }
        cell.bind(delegate: self)
        return cell
    }

    private func dequeueCommentCell(
        in collectionView: UICollectionView, with indexPath: IndexPath
    ) -> CommentCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CommentCell.identifier,
            for: indexPath) as? CommentCell
        else { return CommentCell() }
        let sections = collectionView.numberOfSections
        cell.configure(
            text: self.createMessage(by: indexPath.section, with: sections)
        )
        return cell
    }

    private func dequeueTravelCardCell(
        in collectionView: UICollectionView, with indexPath: IndexPath, using item: Travel
    ) -> TravelCardCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TravelCardCell.identifier,
            for: indexPath) as? TravelCardCell
        else { return TravelCardCell() }
        cell.configure(with: item)
        return cell
    }

    private func createMessage(by section: Int, with sections: Int) -> String {
        let dictionary = ["", "예정된 여행이 없어요 🤷‍♀️", "진행중인 여행이 없어요 🤷", "지난 여행이 없어요 🤷‍♂️"]
        return dictionary[self.sectionIndex(by: section, with: sections)]
    }

    private func createTitle(by section: Int, with sections: Int) -> String {
        let dictionary = ["", "예정된 여행", "진행중인 여행", "지난 여행"]
        return dictionary[self.sectionIndex(by: section, with: sections)]
    }

    private func sectionIndex(by section: Int, with sections: Int) -> Int {
        let allSectionsCount = Travel.Section.allCases.count
        if allSectionsCount == sections { return section }
        return section + 1 // If dummy section is removed, section index should be increased by one.
    }

    private func configureSupplementaryView(
        collectionView: UICollectionView, kind: String, indexPath: IndexPath
    ) -> UICollectionReusableView? {
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: TravelSectionHeader.identifier, for: indexPath
        ) as? TravelSectionHeader
        else { return UICollectionReusableView() }
        let sections = collectionView.numberOfSections
        sectionHeader.configure(
            sectionTitle: self.createTitle(by: indexPath.section, with: sections)
        )
        return sectionHeader
    }

    @IBAction func didTouchSettingButton(_ sender: UIButton) {}

    @IBAction func didTouchCreateButton(_ sender: UIButton) {
        self.viewModel?.didTouchCreateButton()
    }

}

extension HomeViewController: UICollectionViewDelegate, MessageCellDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let travel = self.diffableDataSource?.itemIdentifier(for: indexPath)
        else { return }
        self.viewModel?.didTouchTravel(
            flag: travel.flag, item: indexPath.item
        )
    }

    func didTouchButton() {
        self.viewModel?.didTouchCreateButton()
    }
}

fileprivate extension HomeViewController {

    struct ElementKind {
        static let background = "homeBackground"
    }
}
