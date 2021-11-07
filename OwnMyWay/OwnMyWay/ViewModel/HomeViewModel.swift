//
//  HomeViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import Foundation

protocol HomeViewModelType {
    var reservedTravelCount: Int { get }

    var reservedTravelPublisher: Published<[Travel]>.Publisher { get }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { get }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { get }

    func configure()
}

class HomeViewModel: HomeViewModelType {
    @Published private(set) var reservedTravelCount: Int

    @Published private var reservedTravels: [Travel]
    @Published private var ongoingTravels: [Travel]
    @Published private var outdatedTravels: [Travel]

    var reservedTravelPublisher: Published<[Travel]>.Publisher { $reservedTravels }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { $ongoingTravels }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { $outdatedTravels }

    private let homeUsecase: HomeUsecase

    init(homeUsecase: HomeUsecase) {
        self.reservedTravelCount = 0
        self.reservedTravels = []
        self.ongoingTravels = []
        self.outdatedTravels = []
        self.homeUsecase = homeUsecase
    }

    func configure() {
        self.homeUsecase.executeFetch { [weak self] travels in
            self?.reservedTravels = travels.filter { $0.flag == 0 }
            self?.ongoingTravels = travels.filter { $0.flag == 1 }
            self?.outdatedTravels = travels.filter { $0.flag == 2 }
        }
    }

}
