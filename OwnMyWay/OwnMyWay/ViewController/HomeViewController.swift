//
//  ViewController.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/01.
//

import Combine
import UIKit

typealias HomeDataSource = UICollectionViewDiffableDataSource <HomeViewController.Section, Travel>

class HomeViewController: UIViewController, Instantiable {

    @IBOutlet private weak var travelCollectionView: UICollectionView!

    private var viewModel: HomeViewModelType?
    private var diffableDataSource: HomeDataSource?
    private var cancellables: Set<AnyCancellable>?

    var coordinator: HomeCoordinator?

    enum Section: Int, CaseIterable {
        case reserved = 0
        case ongoing = 1
        case outdated = 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUsecase()
        self.setTravelCollectionView()
//        self.bindUI()
        self.configureCancellables()
        self.viewModel?.configure()
    }

    private func setUsecase() {
        let usecase = DefaultHomeUsecase(travelRepository: CoreDataTravelRepository())
        self.viewModel = HomeViewModel(homeUsecase: usecase)
    }

    private func setTravelCollectionView() {
        self.diffableDataSource = createDiffableDataSource()
//        self.travelCollectionView.delegate = self
//        self.travelCollectionView.dataSource = self
    }

    private func configureCancellables() {
        guard let viewModel = viewModel,
              var cancellables = cancellables
        else { return }
        viewModel.reservedTravelPublisher.sink { [weak self] travels in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Travel>()
            let reservedSnapshotItem = travels.filter { $0.flag == 0 }
            snapshot.append(reservedSnapshotItem)
            self?.diffableDataSource?.apply(snapshot, to: .ongoing, animatingDifferences: true)
        }.store(in: &cancellables)

        viewModel.ongoingTravelPublisher.sink { [weak self] travels in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Travel>()
            let reservedSnapshotItem = travels.filter { $0.flag == 1 }
            snapshot.append(reservedSnapshotItem)
            self?.diffableDataSource?.apply(snapshot, to: .ongoing, animatingDifferences: true)
        }.store(in: &cancellables)

        viewModel.outdatedTravelPublisher.sink { [weak self] travels in
            var snapshot = NSDiffableDataSourceSectionSnapshot<Travel>()
            let reservedSnapshotItem = travels.filter { $0.flag == 2 }
            snapshot.append(reservedSnapshotItem)
            self?.diffableDataSource?.apply(snapshot, to: .ongoing, animatingDifferences: true)
        }.store(in: &cancellables)
    }

    private func createDiffableDataSource() -> HomeDataSource {
        let dataSource = HomeDataSource(
            collectionView: self.travelCollectionView) { collectionView, indexPath, item in
                guard let viewModel = self.viewModel else { return UICollectionViewCell() }

                switch (indexPath.section, indexPath.item) {
                case (0, viewModel.reservedTravelCount):
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: PlusCell.identifier,
                        for: indexPath) as? PlusCell
                    else { return UICollectionViewCell() }
                    cell.bind()
                    return cell
                default:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: TravelCardCell.identifier,
                        for: indexPath) as? TravelCardCell
                    else { return UICollectionViewCell() }
                    cell.setAppearance(travel: item)
                    return cell
                }
        }
        return dataSource
    }

    @IBAction func onbuttonpressed(_ sender: Any) {
        coordinator?.pushToCreateTravel()
    }
}

//extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // MARK: 하드코딩하면 안될거같음
//        guard let myTravels = myTravels else {
//            return 0
//        }
//        return myTravels[section].count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TravelCardCell", for: indexPath) as? TravelCardCell,
//              let myTravels = myTravels else {
//            return UICollectionViewCell()
//        }
//        cell.setAppearance(travel: myTravels[indexPath.section][indexPath.item])
//        return cell
//    }
//
//}
