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
    var photoPublisher: Published<[URL]>.Publisher { get }

    func didEnterTitle(with text: String?)
    func didEnterTime(with date: Date?)
    func didEnterCoordinate(of location: Location)
    func didEnterContent(with text: String?)
    func didEnterPhotoURL(with url: URL)
    func didRemovePhotoURL(with url: URL)
    func didTouchBackButton()
    func didTouchSubmitButton()
    // TODO: Photo 들어왔을 때 처리 함수 추가
}

protocol AddRecordCoordinatingDelegate: AnyObject {
    func popToParent(with record: Record?)
}

class DefaultAddRecordViewModel: AddRecordViewModel {
    var validatePublisher: Published<Bool?>.Publisher { $validateResult }
    var photoPublisher: Published<[URL]>.Publisher { $recordPhotos }

    private var travel: Travel
    private let usecase: AddRecordUsecase
    private weak var coordinatingDelegate: AddRecordCoordinatingDelegate?

    @Published private var validateResult: Bool?
    @Published private var recordPhotos: [URL]
    private var recordTitle: String?
    private var recordDate: Date?
    private var recordCoordinate: Location?
    private var recordPlace: String?
    private var recordContent: String?
    private var plusCard: URL?
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
        self.plusCard = Bundle.main.url(forResource: "addImage", withExtension: "png")
        self.recordPhotos = []
        if let plusCard = plusCard {
            self.recordPhotos.append(plusCard)
        }
    }

    func didEnterTitle(with text: String?) {
        self.recordTitle = text
        self.isValidTitle = self.usecase.executeValidationTitle(with: text)
    }

    func didEnterTime(with date: Date?) {
        self.recordDate = date
        self.isValidDate = self.usecase.executeValidationDate(with: date)
    }

    func didEnterCoordinate(of location: Location) {
        self.recordCoordinate = location
        self.isValidCoordinate = self.usecase.executeValidationCoordinate(with: location)
    }

    func didEnterContent(with text: String?) {
        self.recordContent = text
    }

    func didTouchBackButton() {
        self.coordinatingDelegate?.popToParent(with: nil)
    }

    func didEnterPhotoURL(with url: URL) {
        self.usecase.executePickingPhoto(with: url) { [weak self] url, error in
            guard error == nil,
                  let copiedURL = url
            else { return }
            self?.recordPhotos.append(copiedURL)
        }
    }

    func didRemovePhotoURL(with url: URL) {
        guard let index = self.recordPhotos.firstIndex(of: url)
        else { return }
        self.usecase.executeRemovingPhoto(with: url) { [weak self] success, error in
            guard error == nil,
                  success
            else { return }
            self?.recordPhotos.remove(at: index)
        }
    }

    func didTouchSubmitButton() {
        guard let recordTitle = self.recordTitle,
              let date = self.recordDate,
              let latitude = self.recordCoordinate?.latitude,
              let longtitude = self.recordCoordinate?.longitude,
              let place = self.recordPlace
        else { return }
        let record = Record(
            uuid: nil, title: recordTitle, content: self.recordContent,
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
