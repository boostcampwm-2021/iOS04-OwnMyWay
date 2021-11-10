//
//  HomeViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import Foundation

protocol HomeViewModel {
    var reservedTravelPublisher: Published<[Travel]>.Publisher { get }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { get }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { get }

    func viewDidLoad()
    func didTouchCreateButton()
    func didTouchReservedTravel(at index: Int)
    func didTouchOngoingTravel(at index: Int)
}

protocol HomeCoordinatingDelegate: AnyObject {
    func pushToCreateTravel()
    func pushToReservedTravel(travel: Travel)
    func pushToOngoingTravel(travel: Travel)
}

class DefaultHomeViewModel: HomeViewModel {

    var reservedTravelPublisher: Published<[Travel]>.Publisher { $reservedTravels }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { $ongoingTravels }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { $outdatedTravels }

    private let usecase: HomeUsecase
    private weak var coordinatingDelegate: HomeCoordinatingDelegate?

    @Published private var reservedTravels: [Travel]
    @Published private var ongoingTravels: [Travel]
    @Published private var outdatedTravels: [Travel]

    init(usecase: HomeUsecase, coordinatingDelegate: HomeCoordinatingDelegate) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.reservedTravels = []
        self.ongoingTravels = []
        self.outdatedTravels = []
    }

    func viewDidLoad() {
        self.usecase.executeFetch { [weak self] travels in
            guard let self = self else { return }
            let plusCard = Travel.dummy(section: .plusButton)
            self.reservedTravels = [plusCard] + travels.filter {
                $0.flag == Travel.Section.reserved.index
            }
            self.ongoingTravels = travels.filter { $0.flag == Travel.Section.ongoing.index }
            self.outdatedTravels = travels.filter { $0.flag == Travel.Section.outdated.index }
        }
    }

    func didTouchCreateButton() {
        self.coordinatingDelegate?.pushToCreateTravel()
    }

    func didTouchReservedTravel(at index: Int) {
        guard reservedTravels.startIndex + 1..<reservedTravels.endIndex ~= index else { return }
        self.coordinatingDelegate?.pushToReservedTravel(travel: reservedTravels[index])
    }

    func didTouchOngoingTravel(at index: Int) {
        guard ongoingTravels.startIndex + 1..<ongoingTravels.endIndex ~= index else { return }
        self.coordinatingDelegate?.pushToOngoingTravel(travel: ongoingTravels[index])
    }
}
