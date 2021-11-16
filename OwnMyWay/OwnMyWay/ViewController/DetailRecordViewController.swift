//
//  DetailRecordViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Combine
import UIKit

class DetailRecordViewController: UIViewController, Instantiable {

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!

    private var viewModel: DetailRecordViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCancellable()
    }

    func bind(viewModel: DetailRecordViewModel) {
        self.viewModel = viewModel
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
        }.store(in: &self.cancellables)
    }
}

fileprivate extension UIStackView {
    func removeAllArranged() {
        let subviews = self.arrangedSubviews
        subviews.forEach { self.removeArrangedSubview($0) }
    }
}
