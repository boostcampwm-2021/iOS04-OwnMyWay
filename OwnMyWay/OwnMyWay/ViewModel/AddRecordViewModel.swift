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
    var recordPublisher: Published<Record>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    var record: Record { get }

    func locationDidUpdate(recordPlace: String?, latitude: Double, longitude: Double)
    func didEnterTitle(with text: String?)
    func didEnterTime(with date: Date?)
    func didEnterCoordinate(latitude: Double?, longitude: Double?)
    func didEnterContent(with text: String?)
    func didEnterPhotoURL(with url: URL)
    func didRemovePhoto(at index: Int)
    func didTouchSubmitButton()
    func didTouchLocationButton()
    func didTouchBackButton()
    func configurePlace(latitude: Double?, longitude: Double?)
}

protocol AddRecordCoordinatingDelegate: AnyObject {
    func popToParent(with record: Record)
    func presentToSearchLocation()
}

class DefaultAddRecordViewModel: AddRecordViewModel {

    var validatePublisher: Published<Bool?>.Publisher { $validateResult }
    var recordPublisher: Published<Record>.Publisher { $record }
    var errorPublisher: Published<Error?>.Publisher { $error }

    private let usecase: AddRecordUsecase
    private weak var coordinatingDelegate: AddRecordCoordinatingDelegate?

    @Published private var validateResult: Bool?
    @Published private(set) var record: Record
    @Published private var error: Error?
    private var tempPhotoURLs: [URL]
    private var deletedPhotoURLs: [URL]

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
        self.tempPhotoURLs = []
        self.deletedPhotoURLs = []
        self.record = record ?? Record(
            uuid: UUID(), title: nil, content: nil,
            date: nil, latitude: nil, longitude: nil,
            photoURLs: [], placeDescription: nil
        )
        self.configureRecord()
    }

    func locationDidUpdate(recordPlace: String?, latitude: Double, longitude: Double) {
        self.record.placeDescription = recordPlace
        self.record.latitude = latitude
        self.record.longitude = longitude
        self.isValidCoordinate = self.usecase.executeValidationCoordinate(
            with: Location(latitude: latitude, longitude: longitude)
        )
    }

    func didEnterTitle(with text: String?) {
        self.record.title = text
        self.isValidTitle = self.usecase.executeValidationTitle(with: text)
    }

    func didEnterTime(with date: Date?) {
        self.record.date = date
        self.isValidDate = self.usecase.executeValidationDate(with: date)
    }

    func didEnterCoordinate(latitude: Double?, longitude: Double?) {
        let location = Location(latitude: latitude, longitude: longitude)
        self.record.latitude = latitude
        self.record.longitude = longitude
        self.isValidCoordinate = self.usecase.executeValidationCoordinate(with: location)
    }

    func didEnterContent(with text: String?) {
        self.record.content = text
    }

    func didEnterPhotoURL(with url: URL) {
        self.usecase.executePickingPhoto(with: url) { [weak self] url, error in
            guard error == nil,
                  let copiedURL = url
            else {
                self?.error = error
                return
            }
            self?.record.photoURLs?.append(copiedURL)
            self?.tempPhotoURLs.append(copiedURL)
            self?.isValidPhotos = true
        }
    }

    func didRemovePhoto(at index: Int) {
        guard let url = self.record.photoURLs?[index] else {
            self.error = ModelError.indexError
            return
        }
        self.deletedPhotoURLs.append(url)
        self.record.photoURLs?.remove(at: index)
        self.isValidPhotos = self.record.photoURLs?.count == 0 ? false : true
    }

    func didTouchSubmitButton() {
        self.deletedPhotoURLs.forEach { [weak self] url in
            self?.usecase.executeRemovingPhoto(url: url) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.error = error
                }
            }
        }
        self.coordinatingDelegate?.popToParent(with: record)
    }

    func didTouchLocationButton() {
        self.coordinatingDelegate?.presentToSearchLocation()
    }

    func didTouchBackButton() {
        self.tempPhotoURLs.forEach { [weak self] url in
            self?.usecase.executeRemovingPhoto(url: url) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }

    func configurePlace(latitude: Double?, longitude: Double?) {
        guard let latitude = latitude,
              let longitude = longitude
        else {
            self.record.placeDescription = "🤷‍♂️ 위치를 입력해주세요."
            self.isValidPlace = false
            return
        }

        self.addressName(
            latitude: latitude, longitude: longitude
        ) { [weak self] place in
            guard let self = self else { return }
            self.record.placeDescription = place
            self.isValidPlace = true
        }
    }

    private func configureRecord() {
        self.didEnterTitle(with: self.record.title)
        self.didEnterTime(with: self.record.date)
        self.didEnterCoordinate(latitude: self.record.latitude, longitude: self.record.longitude)
        if record.photoURLs?.count != 0 { self.isValidPhotos = true }
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
