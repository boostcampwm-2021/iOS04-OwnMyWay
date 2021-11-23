//
//  DetailImageViewController.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import UIKit

class DetailImageViewController: UIViewController, Instantiable {

    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    private var viewModel: DetailImageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageScrollView.delegate = self
        self.viewModel?.imageURLs.forEach { url in
            let imageView = configureImageView(with: url)
            let zoomView = configureZoomView()
            self.addSubViewAndConfigureConstraints(imageView: imageView, zoomView: zoomView)
        }
    }

    func bind(viewModel: DetailImageViewModel) {
        self.viewModel = viewModel
    }

    private func configureImageView(with url: URL) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setImage(with: url)
        return imageView
    }

    private func configureZoomView() -> UIScrollView {
        let zoomView = UIScrollView()
        zoomView.showsHorizontalScrollIndicator = false
        zoomView.showsVerticalScrollIndicator = false
        zoomView.maximumZoomScale = 3.0
        zoomView.delegate = self
        zoomView.translatesAutoresizingMaskIntoConstraints = false
        zoomView.autoresizesSubviews = true
        return zoomView
    }

    private func addSubViewAndConfigureConstraints(imageView: UIImageView, zoomView: UIScrollView) {
        zoomView.addSubview(imageView)
        self.imageStackView.addArrangedSubview(zoomView)
        NSLayoutConstraint.activate([
            zoomView.widthAnchor.constraint(equalTo: imageScrollView.frameLayoutGuide.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: zoomView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: zoomView.centerYAnchor),
            imageView.topAnchor.constraint(equalTo: zoomView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: zoomView.contentLayoutGuide.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: zoomView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: zoomView.contentLayoutGuide.trailingAnchor)
        ])
    }

    @IBAction func didTouchBackButton(_ sender: Any) {
        self.viewModel?.didTouchBackButton()
    }
}

extension DetailImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }
}
