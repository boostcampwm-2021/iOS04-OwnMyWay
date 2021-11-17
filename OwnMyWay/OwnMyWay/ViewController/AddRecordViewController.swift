//
//  AddRecordViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import UIKit
import PhotosUI

let supportedPhotoExtensions = [
    UTType.rawImage.identifier,
    UTType.tiff.identifier,
    UTType.bmp.identifier,
    UTType.png.identifier,
    UTType.heif.identifier,
    UTType.heic.identifier,
    UTType.jpeg.identifier,
    UTType.webP.identifier,
    UTType.gif.identifier
]

class AddRecordViewController: UIViewController, Instantiable {
    @IBOutlet private weak var photoCollectionView: UICollectionView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextField: UITextField!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var locationButton: UIButton!

    private var viewModel: AddRecordViewModel?
    private var dataSource: [URL] = []
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.configureGestureRecognizer()
//        self.configureNotifications()
        self.configureNibs()
        self.configurePhotoCollectionView()
        self.configureNavigation()
        self.configureCancellable()
        self.viewModel?.viewDidLoad { [weak self] record in
            self?.titleTextField.text = record.title
            self?.datePicker.date = record.date ?? Date()
            self?.contentTextField.text = record.content
            guard let latitude = record.latitude,
                  let longitude = record.longitude
            else { return }
            self?.getAddressFromCoordinates(
                latitude: latitude, longitude: longitude
            ) { [weak self] title in
                self?.locationButton.setTitle(title, for: .normal)
            }
        }
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }

    private func configureNibs() {
        self.photoCollectionView.register(
            UINib(nibName: PhotoCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PhotoCell.identifier
        )
    }

    private func configurePhotoCollectionView() {
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }

    private func configureNavigation() {
        self.navigationItem.title = "게시물 작성"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(submitButtonAction)
        )
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid ?? false
            }
            .store(in: &cancellables)

        self.viewModel?.photoPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] photos in
                self?.dataSource = photos
                self?.photoCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func submitButtonAction() {
        self.viewModel?.didTouchSubmitButton()
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(with: sender.text)
    }

    @IBAction func didChangeContent(_ sender: UITextField) {
        self.viewModel?.didEnterContent(with: sender.text)
    }

    @IBAction func didChangeDate(_ sender: UIDatePicker) {
        self.viewModel?.didEnterTime(with: sender.date)
    }
}

extension AddRecordViewController {
    private func configureGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowAction(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideAction(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func deleteNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc private func keyboardWillShowAction(_ notification: Notification) {
        let optDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        let optSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
        guard let duration = optDuration as? Double,
              let keyboard = (optSize as? NSValue)?.cgRectValue
        else { return }
        let height = keyboard.height - self.view.safeAreaInsets.bottom

        UIView.animate(withDuration: duration) {
            self.view.frame.move(horizontal: 0, vertical: -height)
        }
    }

    @objc private func keyboardWillHideAction(_ notification: Notification) {
        let optDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]
        guard let duration = optDuration as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.view.frame.moveToZero()
        }
    }
}

extension AddRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return self.dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier, for: indexPath
        ) as? PhotoCell
        else { return UICollectionViewCell() }
        cell.configure(url: self.dataSource[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self.openPicker()
        }
    }

}

extension AddRecordViewController: PHPickerViewControllerDelegate {

    func openPicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 0
        config.filter = PHPickerFilter.images

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
          dismiss(animated: true, completion: nil)
          return
        }
        results.forEach { [weak self] result in
            guard let assetId = result.assetIdentifier else { return }
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
            let date = assetResults.firstObject?.creationDate ?? Date()
            self?.viewModel?.didEnterTime(with: date)
            self?.datePicker.date = date
            if let latitude = assetResults.firstObject?.location?.coordinate.latitude.magnitude,
               let longitude = assetResults.firstObject?.location?.coordinate.longitude.magnitude {
                self?.getAddressFromCoordinates(latitude: latitude, longitude: longitude) { title in
                    self?.viewModel?.didEnterCoordinate(of: Location(latitude: latitude, longitude: longitude))
                    self?.locationButton.setTitle(title, for: .normal)
                }
            }
            for type in supportedPhotoExtensions {
                if result.itemProvider.hasRepresentationConforming(toTypeIdentifier: type, fileOptions: .init()) {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
                        guard error == nil,
                              let url = url else { return }
                        self?.viewModel?.didEnterPhotoURL(with: url)
                    }
                    break
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

}

extension AddRecordViewController {

    func getAddressFromCoordinates(latitude: Double,
                                   longitude: Double,
                                   completion: @escaping (String) -> Void) {
        var center = CLLocationCoordinate2D()
        let geocoder: CLGeocoder = CLGeocoder()
        center.latitude = latitude
        center.longitude = longitude
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            guard error == nil,
                  let placemark = placemarks?.first
            else { return }
            dump(placemark)
            if let name = placemark.name {
                print(name)
                completion(name)
                return
            }
            if let country = placemark.country,
               let region = placemark.region {
                print(country, region)
                completion("\(country) \(region)")
                return
            }
            completion("\(latitude), \(longitude)")
            return
        }
    }
}

fileprivate extension CGRect {
    mutating func move(horizontal: CGFloat, vertical: CGFloat) {
        self = CGRect(
            origin: CGPoint(x: self.origin.x + horizontal, y: self.origin.y + vertical),
            size: self.size
        )
    }

    mutating func moveToZero() {
        self = CGRect(origin: .zero, size: self.size)
    }
}
