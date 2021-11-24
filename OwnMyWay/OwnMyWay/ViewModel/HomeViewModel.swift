//
//  HomeViewModel.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/04.
//

import Foundation

protocol HomeViewModel {
    var messagePublisher: Published<[Travel]>.Publisher { get }
    var reservedTravelPublisher: Published<[Travel]>.Publisher { get }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { get }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }

    func viewDidLoad()
    func didTouchCreateButton()
    func didTouchTravel(flag: Int, item: Int)
}

protocol HomeCoordinatingDelegate: AnyObject {
    func pushToCreateTravel()
    func pushToReservedTravel(travel: Travel)
    func pushToOngoingTravel(travel: Travel)
    func pushToOutdatedTravel(travel: Travel)
}

class DefaultHomeViewModel: HomeViewModel {

    var messagePublisher: Published<[Travel]>.Publisher { $travelMessage }
    var reservedTravelPublisher: Published<[Travel]>.Publisher { $reservedTravels }
    var ongoingTravelPublisher: Published<[Travel]>.Publisher { $ongoingTravels }
    var outdatedTravelPublisher: Published<[Travel]>.Publisher { $outdatedTravels }
    var errorPublisher: Published<Error?>.Publisher { $error }

    private let usecase: HomeUsecase
    private weak var coordinatingDelegate: HomeCoordinatingDelegate?
    private let message: Travel
    private let reservedComment: Travel
    private let ongoingComment: Travel
    private let outdatedComment: Travel

    @Published private var travelMessage: [Travel]
    @Published private var reservedTravels: [Travel]
    @Published private var ongoingTravels: [Travel]
    @Published private var outdatedTravels: [Travel]
    @Published private var error: Error?

    init(usecase: HomeUsecase, coordinatingDelegate: HomeCoordinatingDelegate) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.reservedTravels = []
        self.ongoingTravels = []
        self.outdatedTravels = []
        self.travelMessage = []

        self.message = Travel.dummy(section: .dummy)
        self.reservedComment = Travel.dummy(section: .dummy)
        self.ongoingComment = Travel.dummy(section: .dummy)
        self.outdatedComment = Travel.dummy(section: .dummy)
    }

    func viewDidLoad() {
        self.usecase.executeFetch { [weak self] result in
            switch result {
            case .success(let travels):
                guard let self = self else { return }
                let reserveds = travels.filter { $0.flag == Travel.Section.reserved.index }
                self.reservedTravels = reserveds.isEmpty ? [self.reservedComment] : reserveds
                self.travelMessage = reserveds.isEmpty ? [self.message] : []
                let ongoings = travels.filter { $0.flag == Travel.Section.ongoing.index }
                self.ongoingTravels = ongoings.isEmpty ? [self.ongoingComment] : ongoings
                let outdateds = travels.filter { $0.flag == Travel.Section.outdated.index }
                self.outdatedTravels = outdateds.isEmpty ? [self.outdatedComment] : outdateds
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didTouchCreateButton() {
        self.coordinatingDelegate?.pushToCreateTravel()
    }

    func didTouchTravel(flag: Int, item: Int) {
        switch flag {
        case Travel.Section.reserved.index:
            self.didTouchReservedTravel(at: item)
        case Travel.Section.ongoing.index:
            self.didTouchOngoingTravel(at: item)
        case Travel.Section.outdated.index:
            self.didTouchOutdatedTravel(at: item)
        default:
            return
        }
    }

    private func didTouchReservedTravel(at index: Int) {
        guard reservedTravels.startIndex..<reservedTravels.endIndex ~= index else {
            self.error = ModelError.indexError
            return
        }
        self.coordinatingDelegate?.pushToReservedTravel(travel: reservedTravels[index])
    }

    private func didTouchOngoingTravel(at index: Int) {
        guard ongoingTravels.startIndex..<ongoingTravels.endIndex ~= index else {
            self.error = ModelError.indexError
            return
        }
        self.coordinatingDelegate?.pushToOngoingTravel(travel: ongoingTravels[index])
    }

    private func didTouchOutdatedTravel(at index: Int) {
        guard outdatedTravels.startIndex..<outdatedTravels.endIndex ~= index else {
            self.error = ModelError.indexError
            return
        }
        self.coordinatingDelegate?.pushToOutdatedTravel(travel: outdatedTravels[index])
    }
}
