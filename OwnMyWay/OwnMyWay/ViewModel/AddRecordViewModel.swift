//
//  AddRecordViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation
import MapKit

protocol AddRecordViewModel {
    var validatePublisher: Published<Bool?>.Publisher { get }
    var photoPublisher: Published<[URL]>.Publisher { get }
    var placePublisher: Published<String?>.Publisher { get }
    var datePublisher: Published<Date?>.Publisher { get }

    func viewDidLoad(completion: (Record) -> Void)
    func didEnterTitle(with text: String?)
    func didEnterTime(with date: Date?)
    func didEnterCoordinate(latitude: Double?, longitude: Double?)
    func didEnterContent(with text: String?)
    func didEnterPhotoURL(with url: URL)
    func didRemovePhotoURL(with url: URL)
    func didTouchSubmitButton()
}

protocol AddRecordCoordinatingDelegate: AnyObject {
    func popToParent(with record: Record)
}

class DefaultAddRecordViewModel: AddRecordViewModel {

    var validatePublisher: Published<Bool?>.Publisher { $validateResult }
    var photoPublisher: Published<[URL]>.Publisher { $recordPhotos }
    var placePublisher: Published<String?>.Publisher { $recordPlace }
    var datePublisher: Published<Date?>.Publisher { $recordDate }

    private let usecase: AddRecordUsecase
    private weak var coordinatingDelegate: AddRecordCoordinatingDelegate?

    @Published private var validateResult: Bool?
    @Published private var recordPhotos: [URL]
    @Published private var recordPlace: String?
    @Published private var recordDate: Date?

    private var recordID: UUID?
    private var recordTitle: String?
    private var recordCoordinate: Location?
    private var recordContent: String?
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
        record: Record?,
        usecase: AddRecordUsecase,
        coordinatingDelegate: AddRecordCoordinatingDelegate
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.recordPhotos = []
        self.configurePlusCard()
        self.configureRecord(with: record)
    }

    func viewDidLoad(completion: (Record) -> Void) {
        let record = Record(
            uuid: nil, title: self.recordTitle, content: self.recordContent,
            date: self.recordDate, latitude: self.recordCoordinate?.latitude,
            longitude: self.recordCoordinate?.longitude, photoURLs: self.recordPhotos,
            placeDescription: self.recordPlace
        )
        completion(record)
    }

    func didEnterTitle(with text: String?) {
        self.recordTitle = text
        self.isValidTitle = self.usecase.executeValidationTitle(with: text)
    }

    func didEnterTime(with date: Date?) {
        self.recordDate = date
        self.isValidDate = self.usecase.executeValidationDate(with: date)
    }

    func didEnterCoordinate(latitude: Double?, longitude: Double?) {
        let location = Location(latitude: latitude, longitude: longitude)
        self.recordCoordinate = location
        //self.isValidCoordinate = self.usecase.executeValidationCoordinate(with: location)
        self.isValidCoordinate = true
        self.configurePlace(latitude: latitude, longitude: longitude)
    }

    func didEnterContent(with text: String?) {
        self.recordContent = text
    }

    func didEnterPhotoURL(with url: URL) {
        self.usecase.executePickingPhoto(with: url) { [weak self] url, error in
            guard error == nil,
                  let copiedURL = url
            else { return }
            self?.recordPhotos.append(copiedURL)
            self?.isValidPhotos = true
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
//              let latitude = self.recordCoordinate?.latitude,
//              let longtitude = self.recordCoordinate?.longitude,
              let place = self.recordPlace
        else { return }
        self.recordPhotos.removeFirst()
        let record = Record(
            uuid: self.recordID ?? UUID(), title: recordTitle, content: self.recordContent,
            date: date, latitude: self.recordCoordinate?.latitude, longitude: self.recordCoordinate?.longitude,
            photoURLs: recordPhotos, placeDescription: place
        )
        self.coordinatingDelegate?.popToParent(with: record)
    }

    private func configurePlusCard() {
        if let plusCard = Bundle.main.url(forResource: "addImage", withExtension: "png") {
            self.recordPhotos.append(plusCard)
        }
    }

    private func configureRecord(with record: Record?) {
        if let record = record {
            self.recordID = record.uuid
            self.didEnterTitle(with: record.title)
            self.didEnterTime(with: record.date)
            self.didEnterCoordinate(latitude: record.latitude, longitude: record.longitude)
            self.didEnterContent(with: record.content)
            record.photoURLs?.forEach { [weak self] url in
                self?.recordPhotos.append(url)
                self?.isValidPhotos = true
            }
        }
    }

    private func configurePlace(latitude: Double?, longitude: Double?) {
        guard let latitude = latitude,
              let longitude = longitude
        else {
            self.recordPlace = "위치정보 없음"
            self.isValidPlace = true
            return
        }
        self.addressName(
            latitude: latitude, longitude: longitude
        ) { [weak self] place in
            guard let self = self,
                  !self.isValidPlace
            else { return }
            self.recordPlace = place
            self.isValidPlace = true
        }
    }

    private func checkValidation() {
        validateResult
        = isValidTitle && isValidDate && isValidCoordinate && isValidPhotos
    }
}

extension AddRecordViewModel {

    func addressName(
        latitude: Double, longitude: Double,
        completion: @escaping (String) -> Void
    ) {
        let location = CLLocation(
            latitude: latitude, longitude: longitude
        )
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil,
                  let placemark = placemarks?.first
            else { return }
            if let name = placemark.name {
                completion(name)
                return
            }
            if let country = placemark.country,
               let region = placemark.region {
                completion("\(country) \(region)")
                return
            }
            completion("위치를 찾을 수 없어요. 직접 지정해주세요.")
            return
        }
    }

}
