//
//  AddRecordViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation

protocol AddRecordViewModel {
    var validatePublisher: Published<Bool?>.Publisher { get }

    func didEnterTitle(with text: String?)
    func didEnterTime(with date: Date?)
    func didEnterCoordinate(at location: Location)
    func didTouchBackButton()
    func didTouchSubmitButton()
    // TODO: Photo 들어왔을 때 처리 함수 추가
}

protocol AddRecordCoordinatingDelegate: AnyObject {
    func popToParent(with record: Record?)
}

class DefaultAddRecordViewModel: AddRecordViewModel {
    var validatePublisher: Published<Bool?>.Publisher { $validateResult }

    private var travel: Travel
    private let usecase: AddRecordUsecase
    private weak var coordinatingDelegate: AddRecordCoordinatingDelegate?

    @Published private var validateResult: Bool?
    private var recordTitle: String?
    private var recordDate: Date?
    private var recordCoordinate: Location?
    private var recordPlace: String?
    private var recordContent: String?
    private var recordPhotos: [URL] = []
    private var isValidTitle: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidDate: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidCoordinate: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidPlace: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidPhotos: Bool = false {
        didSet {
            self.checkValidation()
        }
    }

    init(
        travel: Travel,
        usecase: AddRecordUsecase,
        coordinatingDelegate: AddRecordCoordinatingDelegate
    ) {
        self.travel = travel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didEnterTitle(with text: String?) {
        self.recordTitle = text
        self.isValidTitle = self.usecase.executeValidationTitle(with: text)
    }

    func didEnterTime(with date: Date?) {
        self.recordDate = date
        self.isValidDate = self.usecase.executeValidationDate(with: date)
    }

    func didEnterCoordinate(at location: Location) {
        self.recordCoordinate = location
        self.isValidCoordinate = self.usecase.executeValidationCoordinate(with: location)
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToParent(with: nil)
    }

    func didTouchSubmitButton() {
        guard let recordTitle = self.recordTitle,
              let date = self.recordDate,
              let latitude = self.recordCoordinate?.latitude,
              let longtitude = self.recordCoordinate?.longitude,
              let place = self.recordPlace,
              let content = self.recordContent
        else { return }
        let record = Record(
            uuid: nil, title: recordTitle, content: content,
            date: date, latitude: latitude, longitude: longtitude,
            photoURLs: recordPhotos, placeDescription: place
        )
        // TODO: usecase를 통해 coreData 업데이트가 필요함
        self.coordinatingDelegate?.popToParent(with: record)
    }

    private func checkValidation() {
        validateResult
        = isValidTitle && isValidDate && isValidCoordinate && isValidPlace && isValidPhotos
    }
}
