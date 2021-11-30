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
    @IBOutlet private weak var createButton: UIButton!
    private var viewModel: HomeViewModel?
    private var diffableDataSource: HomeDataSource?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()
        self.configureTravelCollectionView()
        self.configureDataSource()
        self.configureCancellable()
        self.fetchTravel()
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
                self?.dataSourceChanged(to: travels, in: .dummy)
            }
            .store(in: &self.cancellables)

        self.viewModel?.reservedTravelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                self?.dataSourceChanged(to: travels, in: .reserved)
            }
            .store(in: &self.cancellables)

        self.viewModel?.ongoingTravelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                self?.dataSourceChanged(to: travels, in: .ongoing)
            }
            .store(in: &self.cancellables)

        self.viewModel?.outdatedTravelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] travels in
                self?.dataSourceChanged(to: travels, in: .outdated)
                if #available(iOS 15.0, *) {
                    return
                } else {
                    self?.travelCollectionView.collectionViewLayout.invalidateLayout()
                }
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

    private func dataSourceChanged(to travels: [Travel], in section: Travel.Section) {
        guard var snapshot = self.diffableDataSource?.snapshot() else { return }
        snapshot.deleteSections([section])
        switch section {
        case .dummy: snapshot.insertSections([.dummy], beforeSection: .reserved)
        case .reserved: snapshot.insertSections([.reserved], beforeSection: .ongoing)
        case .ongoing: snapshot.insertSections([.ongoing], afterSection: .reserved)
        case .outdated: snapshot.insertSections([.outdated], afterSection: .ongoing)
        }
        snapshot.appendItems(travels, toSection: section)
        self.diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, _)
            -> NSCollectionLayoutSection? in
            let section = Travel.Section.allCases[sectionIndex]
            return section == .dummy ? self.createMessageSection() : self.createLayoutSection()
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
        let section = self.createSection(fractionalWidth: 1.0)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0, leading: 0, bottom: 0, trailing: 0
        )
        return section
    }

    private func createLayoutSection() -> NSCollectionLayoutSection {
        let section = self.createSection(fractionalWidth: 0.8)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 25, leading: 20, bottom: 40, trailing: 20
        )
        section.interGroupSpacing = 25
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

    private func createSection(fractionalWidth: Double) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(100)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(fractionalWidth), heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.decorationItems = [
            NSCollectionLayoutDecorationItem.background(elementKind: ElementKind.background)
        ]
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
        return sections == Travel.Section.allCases.count && section == 0
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
        if Travel.Section.allCases.count == sections { return section }
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

    func didTouchCloseButton() {
        self.viewModel?.didTouchCloseMessage()
    }

}

fileprivate extension HomeViewController {

    struct ElementKind {
        static let background = "homeBackground"
    }
}
