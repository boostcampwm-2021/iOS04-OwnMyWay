//
//  AddRecordViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import UIKit
import PhotosUI

@available(iOS 14.0, *)
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

enum TransitionType {
    case cancel, submit
}

class AddRecordViewController: UIViewController, Instantiable {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var photoCollectionView: UICollectionView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var locationButton: UIButton!

    private var viewModel: AddRecordViewModel?
    private var cancellables: Set<AnyCancellable> = []
    private var transitionType: TransitionType = .cancel

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTextView()
        self.configureGestureRecognizer()
        self.configureNotifications()
        self.configureNibs()
        self.configurePhotoCollectionView()
        self.configureCancellable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationController()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent && self.transitionType == .cancel {
            self.viewModel?.didTouchBackButton()
        }
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }

    func update(recordPlace: String?, latitude: Double, longitude: Double) {
        self.viewModel?.locationDidUpdate(
            recordPlace: recordPlace, latitude: latitude, longitude: longitude
        )
    }

    private func configureTextView() {
        self.contentTextView.layer.cornerRadius = 10
        self.contentTextView.textContainerInset = .init(top: 20, left: 15, bottom: 20, right: 15)
        self.contentTextView.delegate = self
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

    private func configureNavigationController() {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(submitButtonAction)
        )
        guard let isEditingMode = self.viewModel?.isEditingMode else { return }
        self.navigationItem.title = isEditingMode ? "게시물 편집" : "게시물 작성"
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid ?? false
            }
            .store(in: &cancellables)

        self.viewModel?.recordPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] record in
                self?.photoCollectionView.reloadData()
                self?.locationButton.setTitle(record.placeDescription, for: .normal)
                self?.datePicker.date = record.date ?? Date()
                self?.titleTextField.text = record.title
                self?.contentTextView.text = record.content
            }
            .store(in: &cancellables)
    }

    @objc private func submitButtonAction() {
        self.transitionType = .submit
        self.viewModel?.didTouchSubmitButton()
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(with: sender.text)
    }

    @IBAction func didChangeDate(_ sender: UIDatePicker) {
        self.viewModel?.didEnterTime(with: sender.date)
    }

    @IBAction func didChangeLocation(_ sender: Any) {
        self.viewModel?.didTouchLocationButton()
    }
}

extension AddRecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.viewModel?.didEnterContent(with: textView.text)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        let scrollPoint: CGPoint = CGPoint.init(
            x: 0, y: textView.frame.origin.y + textView.frame.height
        )
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
}

extension AddRecordViewController {
    private func configureGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGesture.cancelsTouchesInView = false
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
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        self.scrollView.contentInset.bottom = keyboardFrame.size.height
        let firstResponder = self.view.firstResponder
        if let textView = firstResponder as? UITextField {
            self.scrollView.scrollRectToVisible(textView.frame, animated: true)
        }
    }

    @objc private func keyboardWillHideAction(_ notification: Notification) {
        let zeroInset = UIEdgeInsets.zero
        self.scrollView.contentInset = zeroInset
        self.scrollView.scrollIndicatorInsets = zeroInset
    }
}

extension AddRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return (self.viewModel?.record.photoURLs?.count ?? 0) + 1
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier, for: indexPath
        ) as? PhotoCell
        else { return UICollectionViewCell() }

        switch indexPath.item {
        case 0:
            guard let url = Bundle.main.url(forResource: "addImage", withExtension: "png")
            else { return UICollectionViewCell() }
            cell.configure(url: url)
            return cell
        default:
            guard let url = self.viewModel?.record.photoURLs?[indexPath.item - 1]
            else { return UICollectionViewCell() }
            cell.configure(url: url)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            if self.viewModel?.record.photoURLs?.count == self.viewModel?.maxPhotosCount {
                self.showToast(text: "사진은 \(self.viewModel?.record.maxPhotoCount ?? 0)장까지 추가할 수 있어요")
            } else {
                if #available(iOS 14.0, *) {
                    self.openPicker()
                } else {
                    self.openImagePicker()
                }
            }
        default:
            self.viewModel?.didRemovePhoto(at: indexPath.item - 1)
        }
    }
}

extension AddRecordViewController: PHPickerViewControllerDelegate {

    @available (iOS 14.0, *)
    func openPicker() {
        let requiredAccessLevel: PHAccessLevel = .readWrite
        PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { [weak self] status in

            DispatchQueue.main.async {
                switch status {
                case .notDetermined, .restricted, .denied:
                    let alert = UIAlertController(
                        title: "권한 설정이 필요합니다.",
                        message: "Setting -> OwnMyWay -> 사진 -> 선택한 사진 또는 모든 사진",
                        preferredStyle: .alert
                    )

                    let moveAction = UIAlertAction(title: "이동", style: .default) { _ in
                        guard let url = URL(string: UIApplication.openSettingsURLString)
                        else { return }
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }

                    let cancelAction = UIAlertAction(title: "취소", style: .cancel)

                    alert.addAction(moveAction)
                    alert.addAction(cancelAction)

                    self?.present(alert, animated: true)
                default:
                    var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                    guard let photoURLsCount = self?.viewModel?.record.photoURLs?.count, let maxPhotoCount = self?.viewModel?.maxPhotosCount else { return }
                    config.selectionLimit = maxPhotoCount - photoURLsCount
                    config.filter = PHPickerFilter.images

                    let pickerViewController = PHPickerViewController(configuration: config)
                    pickerViewController.delegate = self
                    self?.present(pickerViewController, animated: true, completion: nil)
                }
            }
        }
    }

    @available (iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
          dismiss(animated: true, completion: nil)
          return
        }

        if self.viewModel?.record.photoURLs?.count == 0 { // dummy만 있을 경우 (사진이 없을 때)
            guard let assetId = results[0].assetIdentifier else { return }
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
            let date = assetResults.firstObject?.creationDate ?? Date()
            let coordinate = assetResults.firstObject?.location?.coordinate
            self.viewModel?.didEnterTime(with: date)
            self.viewModel?.didEnterCoordinate(
                latitude: coordinate?.latitude.magnitude,
                longitude: coordinate?.longitude.magnitude
            )
            self.viewModel?.configurePlace(
                latitude: coordinate?.latitude.magnitude,
                longitude: coordinate?.longitude.magnitude
            )
        }

        results.forEach { [weak self] result in
            for type in supportedPhotoExtensions {
                if result.itemProvider.hasRepresentationConforming(
                    toTypeIdentifier: type,
                    fileOptions: .init()
                ) {
                    result.itemProvider.loadFileRepresentation(
                        forTypeIdentifier: type
                    ) { url, error in
                        guard error == nil,
                              let url = url else { return }
                        DispatchQueue.global().sync {
                            self?.viewModel?.didEnterPhotoURL(with: url)
                        }
                    }
                    break
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddRecordViewController: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {
    func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        let status = PHPhotoLibrary.authorizationStatus()

        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    self.present(imagePicker, animated: true)
                }
            }
        case .restricted, .denied:
            let alert = UIAlertController(
                title: "권한 설정이 필요합니다.",
                message: "Setting -> OwnMyWay -> 사진 -> 선택한 사진 또는 모든 사진",
                preferredStyle: .alert
            )
            let moveAction = UIAlertAction(title: "이동", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(moveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true)
        case .authorized, .limited:
            self.present(imagePicker, animated: true)
        @unknown default:
            break
        }
    }

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if self.viewModel?.record.photoURLs?.count == 0 { // dummy만 있을 경우 (사진이 없을 때)
            if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                let date = asset.creationDate ?? Date()
                let coordinate = asset.location?.coordinate
                self.viewModel?.didEnterTime(with: date)
                self.viewModel?.didEnterCoordinate(
                    latitude: coordinate?.latitude.magnitude,
                    longitude: coordinate?.longitude.magnitude
                )
                self.viewModel?.configurePlace(
                    latitude: coordinate?.latitude.magnitude,
                    longitude: coordinate?.longitude.magnitude
                )
            }
        }
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            self.viewModel?.didEnterPhotoURL(with: imageURL)
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - fileprivate extension for UIView
fileprivate extension UIView {
    var firstResponder: UIView? {
        guard !self.isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder { return firstResponder }
        }
        return nil
    }
}
