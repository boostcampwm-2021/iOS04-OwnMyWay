//
//  CreateTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import Foundation

protocol CreateTravelViewModelType {
    var travelTitle: String? { get }
    var travelStartDate: Date? { get }
    var travelEndDate: Date? { get }
    var isPossible: Bool? { get }

    func didEnterTitle(text: String?)
    func didEnterDate(startDate: Date, endDate: Date)
}

class CreateTravelViewModel: CreateTravelViewModelType, ObservableObject {
    var travelTitle: String?
    var travelStartDate: Date?
    var travelEndDate: Date?
    @Published var isPossible: Bool?

    private let createTravelUsecase: CreateTravelUsecase

    init(createTravelUsecase: CreateTravelUsecase) {
        self.createTravelUsecase = createTravelUsecase
    }

    func didEnterTitle(text: String?) {
        guard let text = text else { return }
        self.createTravelUsecase.configTravelTitle(text: text) { [weak self] result in
            switch result {
            case .success(let title):
                self?.travelTitle = title
                self?.isPossible = true
            case .failure:
                self?.isPossible = false
            }
        }
    }

    func didEnterDate(startDate: Date, endDate: Date) {
        self.travelStartDate = startDate
        self.travelEndDate = endDate
    }

    func didTouchMakeButton(completion: @escaping (Travel) -> Void) {
        guard let travelTitle = self.travelTitle,
              let startDate = self.travelStartDate,
              let endDate = self.travelEndDate
        else { return }

        self.createTravelUsecase.makeTravel(title: travelTitle,
                                            startDate: startDate,
                                            endDate: endDate) { travel in
            completion(travel)
        }
    }
}
