//
//  DetailRecordViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Combine
import UIKit

class DetailRecordViewController: UIViewController, Instantiable, RecordUpdatable {

    @IBOutlet private weak var imageScrollView: UIScrollView!
    @IBOutlet private weak var imageStackView: UIStackView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var timeAndLocationLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!

    private var viewModel: DetailRecordViewModel?
    private var cancellables: Set<AnyCancellable> = []

    let documentInteractionController = UIDocumentInteractionController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureScrollView()
        self.configureSettingButton()
        self.configureDocumentInteractionController()
        self.configureCancellable()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            self.viewModel?.didTouchBackButton()
        }
    }

    func bind(viewModel: DetailRecordViewModel) {
        self.viewModel = viewModel
    }

    func didUpdateRecord(record: Record) {
        switch self.viewModel?.didUpdateRecord(record: record) {
        case .success:
            break
        case .failure(let error):
            print(error)
        case .none:
            print("App 터졌다구~")
        }
    }

    private func configureScrollView() {
        self.imageScrollView.delegate = self
    }

    private func configureDocumentInteractionController() {
        self.documentInteractionController.delegate = self
    }

    private func configureSettingButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTouchSettingButton)
        )
    }

    private func configureCancellable() {
        self.viewModel?.recordPublisher.sink { [weak self] record in
            self?.navigationItem.title = "게시물"
            self?.titleLabel.text = record.title
            self?.timeAndLocationLabel.text
            = "\(record.date?.relativeDateTime() ?? "nil"), \(record.placeDescription ?? "nil")에서"
            self?.contentLabel.text = record.content
            self?.imageStackView.removeAllArranged()
            record.photoURLs?.forEach { url in
                let imageView = UIImageView()
                imageView.setImage(with: url)
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
                ])
                self?.imageStackView.addArrangedSubview(imageView)
            }
            self?.configurePageControl(record: record)
        }.store(in: &self.cancellables)
    }

    private func configurePageControl(record: Record) {
        guard let numberOfPages = record.photoURLs?.count else { return }
        self.pageControl.numberOfPages = numberOfPages
    }

    private func configurePageControlSelectedPage(currentPage: Int) {
        self.pageControl.currentPage = currentPage
    }

    private func presentAlert() {
        let alert = UIAlertController(title: "여행 기록 삭제",
                                      message: "기록을 삭제하실건가요?\n소중한 기록은 삭제되면 되돌릴 수 없어요😭",
                                      preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "네", style: .destructive) { [weak self] _ in
            self?.viewModel?.didTouchDeleteButton()
        }
        let noAction = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }

    @objc private func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.presentAlert()
        }

        let editAction = UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            self?.viewModel?.didTouchEditButton()
        }

        let shareAction = UIAlertAction(title: "공유하기", style: .default) { [weak self] _ in
            self?.presentSharedPreview()
        }
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(shareAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
}

// MARK: - UIScollViewDelegate
extension DetailRecordViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = self.imageScrollView.contentOffset.x / self.imageScrollView.frame.size.width
        let currentPage = Int(round(value))
        self.configurePageControlSelectedPage(currentPage: currentPage)
    }
}

// MARK: - UIDocumetntInteractionControllerDelegate & 공유기능
extension DetailRecordViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(
        _ controller: UIDocumentInteractionController
    ) -> UIViewController {
        return self
    }

    private func presentSharedPreview() {
        guard let viewModel = self.viewModel, let superView = self.view
        else { return }
        let polaroidView = UIView()
        superView.addSubview(polaroidView)
        polaroidView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            polaroidView.topAnchor.constraint(equalTo: superView.bottomAnchor),
            polaroidView.centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            polaroidView.widthAnchor.constraint(equalTo: superView.widthAnchor),
            polaroidView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
        polaroidView.makePolaroid(with: viewModel.record)
        let image = self.renderImage(view: polaroidView)
        polaroidView.removeFromSuperview()
        self.documentInteractionController.url = self.save(
            image: image,
            fileName: viewModel.record.title
        )
        self.documentInteractionController.presentPreview(animated: true)
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func renderImage(view: UIView) -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: view.bounds.size
        )
        let image = renderer.image { _ in
            view.drawHierarchy(
                in: view.bounds,
                afterScreenUpdates: true
            )
        }
        return image
    }

    private func save(image: UIImage, fileName: String?) -> URL? {
        guard let data = image.jpegData(compressionQuality: 1.0), let fileName = fileName
        else { return nil }
        let documentDirectory = self.getDocumentsDirectory()
        let filePath = documentDirectory.appendingPathComponent("\(fileName).jpeg")
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            return nil
        }
    }
}

// MARK: - File extension for UIStackView
fileprivate extension UIStackView {
    func removeAllArranged() {
        let subviews = self.arrangedSubviews
        subviews.forEach { $0.removeFromSuperview() }
    }
}
