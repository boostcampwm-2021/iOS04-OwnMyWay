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
        self.documentInteractionController.url = Bundle.main.url(forResource: "iPhone", withExtension: "png")
    }

    private func configureSettingButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(didTouchSettingButton)
        )
    }

    @objc private func didTouchSettingButton() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제하기", style: .destructive) { _ in
            self.viewModel?.didTouchDeleteButton()
        }

        let editAction = UIAlertAction(title: "수정하기", style: .default) { _ in
            self.viewModel?.didTouchEditButton()
        }

        let shareAction = UIAlertAction(title: "공유하기", style: .default) { _ in
            self.documentInteractionController.presentOptionsMenu(from: self.view.bounds, in: self.view, animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소하기", style: .cancel)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(editAction)
        actionSheet.addAction(shareAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }

    private func configureCancellable() {
        self.viewModel?.recordPublisher.sink { record in
            self.navigationItem.title = record.date?.localize()
            self.titleLabel.text = record.title
            self.timeLabel.text = record.date?.time()
            self.locationLabel.text = record.placeDescription
            self.contentLabel.text = record.content
            self.imageStackView.removeAllArranged()
            record.photoURLs?.forEach { url in
                let imageView = UIImageView()
                imageView.setImage(with: url)
                imageView.contentMode = .scaleAspectFit
                NSLayoutConstraint.activate([
                    imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
                ])
                self.imageStackView.addArrangedSubview(imageView)
            }
            self.configurePageControl(record: record)
        }.store(in: &self.cancellables)
    }

    private func configurePageControl(record: Record) {
        guard let numberOfPages = record.photoURLs?.count else { return }
        self.pageControl.numberOfPages = numberOfPages
    }

    private func configurePageControlSelectedPage(currentPage: Int) {
        self.pageControl.currentPage = currentPage
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

// MARK: - UIDocumetntInteractionControllerDelegate
extension DetailRecordViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        self
    }
}

// MARK: - File extension for UIStackView
fileprivate extension UIStackView {
    func removeAllArranged() {
        let subviews = self.arrangedSubviews
        subviews.forEach { self.removeArrangedSubview($0) }
    }
}
