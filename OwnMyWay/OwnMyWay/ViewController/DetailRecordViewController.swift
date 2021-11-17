//
//  DetailRecordViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Combine
import UIKit

class DetailRecordViewController: UIViewController, Instantiable, RecordUpdatable {

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

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
        self.viewModel?.didUpdateRecord(record: record)
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
            self?.navigationItem.title = record.date?.localize()
            self?.titleLabel.text = record.title
            self?.timeLabel.text = record.date?.time()
            self?.locationLabel.text = record.placeDescription
            self?.contentLabel.text = record.content
            self?.imageStackView.removeAllArranged()
            record.photoURLs?.forEach { url in
                let imageView = UIImageView()
                imageView.setImage(with: url)
                imageView.contentMode = .scaleAspectFit
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
        let polaroidView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: self.view.frame.width,
                height: 6 * self.view.frame.width / 7
            )
        )
        polaroidView.makePolaroid(with: viewModel.record)
        superView.addSubview(polaroidView)
        NSLayoutConstraint.activate([
            polaroidView.topAnchor.constraint(equalTo: superView.bottomAnchor),
            polaroidView.leadingAnchor.constraint(equalTo: superView.leadingAnchor)
        ])
        let image = self.renderImage(view: polaroidView)
        polaroidView.removeFromSuperview()
        self.documentInteractionController.url = self.save(
            image: image,
            // FIXME: title로 변경하는게 좋을 것 같아요 근데 지금 더미는 title이 nil이여서 확인차 content로 해놨어요
            fileName: viewModel.record.content
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
        subviews.forEach { self.removeArrangedSubview($0) }
    }
}
