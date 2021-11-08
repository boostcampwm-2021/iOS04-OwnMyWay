//
//  HomeViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import Foundation

protocol HomeViewModelType {
    var reservedTravelPublisher: Published<[Travel]>.Publisher { get }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { get }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { get }

    func configure()
    func createButtonDidTouched()
    func reservedTravelDidTouched(index: Int)
}

protocol HomeCoordinatingDelegate: AnyObject {
    func pushToCreateTravel()
    func pushToReservedTravel(travel: Travel)
}

class HomeViewModel: HomeViewModelType {

    @Published private var reservedTravels: [Travel]
    @Published private var ongoingTravels: [Travel]
    @Published private var outdatedTravels: [Travel]

    var reservedTravelPublisher: Published<[Travel]>.Publisher { $reservedTravels }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { $ongoingTravels }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { $outdatedTravels }

    private let homeUsecase: HomeUsecase
    private weak var coordinator: HomeCoordinatingDelegate?

    init(homeUsecase: HomeUsecase, coordinator: HomeCoordinatingDelegate) {
        self.reservedTravels = []
        self.ongoingTravels = []
        self.outdatedTravels = []
        self.homeUsecase = homeUsecase
        self.coordinator = coordinator
    }

    func configure() {
        self.homeUsecase.executeFetch { [weak self] travels in
            guard let self = self else { return }
            let plusCard = Travel(
                uuid: UUID(),
                flag: -1,
                title: "DummyBoy",
                startDate: Date(),
                endDate: Date(),
                landmarks: [],
                records: []
            )
            self.reservedTravels = [plusCard] + travels.filter {
                $0.flag == Travel.Section.reserved.index
            }
            self.ongoingTravels = travels.filter { $0.flag == Travel.Section.ongoing.index }
            self.outdatedTravels = travels.filter { $0.flag == Travel.Section.outdated.index }
        }
    }

    func createButtonDidTouched() {
        self.coordinator?.pushToCreateTravel()
    }

    func reservedTravelDidTouched(index: Int) {
        guard reservedTravels.startIndex + 1..<reservedTravels.endIndex ~= index else { return }
        self.coordinator?.pushToReservedTravel(travel: reservedTravels[index])
    }

}
