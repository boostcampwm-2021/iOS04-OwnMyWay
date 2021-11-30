//
//  CreateTravelViewModel.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import Combine
import Foundation

protocol EnterTitleViewModel {
    var validatePublisher: Published<Bool?>.Publisher { get }
    var isEditingMode: Bool { get }
    func viewDidLoad(completion: (String?) -> Void)
    func travelDidChanged(to travel: Travel)
    func didChangeTitle(text: String?)
    func didTouchNextButton()
}

final class DefaultEnterTitleViewModel: EnterTitleViewModel, ObservableObject {

    var validatePublisher: Published<Bool?>.Publisher { $isValidTitle }

    private let usecase: EnterTitleUsecase
    private weak var coordinatingDelegate: EnterTitleCoordinatingDelegate?

    @Published private var isValidTitle: Bool?
    private var travel: Travel
    private var travelTitle: String?
    private var travelStartDate: Date?
    private var travelEndDate: Date?
    private(set) var isEditingMode: Bool

    init(
        usecase: EnterTitleUsecase,
        coordinatingDelegate: EnterTitleCoordinatingDelegate,
        travel: Travel?
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.isEditingMode = travel == nil ? false : true
        self.travel = travel ?? Travel.dummy(section: .reserved)
        self.didChangeTitle(text: travel?.title)
    }

    func viewDidLoad(completion: (String?) -> Void) {
        completion(self.travelTitle)
    }

    func travelDidChanged(to travel: Travel) {
        self.travel = travel
    }

    func didChangeTitle(text: String?) {
        guard let text = text else { return }
        self.usecase.executeTitleValidation(with: text) { [weak self] result in
            switch result {
            case .success(let title):
                self?.travelTitle = title
                self?.isValidTitle = true
            case .failure:
                self?.isValidTitle = false
            }
        }
    }

    func didTouchNextButton() {
        self.travel.title = self.travelTitle
        self.coordinatingDelegate?.pushToEnterDate(
            travel: self.travel, isEditingMode: self.isEditingMode
        )
    }
}
