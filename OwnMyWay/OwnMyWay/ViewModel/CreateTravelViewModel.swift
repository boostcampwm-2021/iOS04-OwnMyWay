//
//  CreateTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import Foundation

protocol CreateTravelViewModelType {
    var travelTitle: String? { get set }
    var travelStartDate: Date? { get set }
    var travelEndDate: Date? { get set }
    var isPossible: Bool? { get set }

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
        self.createTravelUsecase.configTravelTitle(text: text) { result in
            switch result {
            case .success(let title):
                self.travelTitle = title
                self.isPossible = true
            case .failure:
                self.isPossible = false
            }
        }
    }

    func didEnterDate(startDate: Date, endDate: Date) {
        self.createTravelUsecase.configTravelDate(startDate: startDate,
                                                  endDate: endDate) { startDate, endDate in
            self.travelStartDate = startDate
            self.travelEndDate = endDate
        }
    }

    func didTouchMakeButton(completion: @escaping (Travel) -> Void) {
        guard let isPossible = self.isPossible,
              let travelTitle = self.travelTitle,
              let startDate = self.travelStartDate,
              let endDate = self.travelEndDate else { return }

        self.createTravelUsecase.makeTravel(isPossible: isPossible,
                                            title: travelTitle,
                                            startDate: startDate,
                                            endDate: endDate) { result  in
            switch result {
            case .success(let travel):
                completion(travel)
            case .failure:
                break // 여행 제작 실패 어떻게 해야할지
            }
        }
    }
}
