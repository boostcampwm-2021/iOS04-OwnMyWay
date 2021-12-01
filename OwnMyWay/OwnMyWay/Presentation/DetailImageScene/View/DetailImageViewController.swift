//
//  DetailImageViewController.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/23.
//

import UIKit

final class DetailImageViewController: UIViewController, Instantiable {

    @IBOutlet private weak var imageStackView: UIStackView!
    @IBOutlet private weak var imageScrollView: UIScrollView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var pageControl: UIPageControl!

    private var viewModel: DetailImageViewModel?
    private var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureScrollView()
        self.configurePageControl()
        self.viewModel?.imageIDs.forEach { url in
            let imageView = configureImageView(
                with: ImageFileManager.shared.imageInDocuemtDirectory(image: url)
            )
            let zoomView = configureZoomView()
            self.addSubViewAndConfigureConstraints(imageView: imageView, zoomView: zoomView)
        }
    }

    override func viewWillLayoutSubviews() {
        guard let selectedIndex = self.viewModel?.selectedIndex else { return }
        let imageWidth = self.imageScrollView.frame.size.width
        self.imageScrollView.setContentOffset(
            CGPoint(x: Int(imageWidth) * selectedIndex, y: 0), animated: false
        )
    }

    func bind(viewModel: DetailImageViewModel) {
        self.viewModel = viewModel
        self.selectedIndex = viewModel.selectedIndex
    }

    private func configureScrollView() {
        self.imageScrollView.delegate = self
    }

    private func configureImageView(with url: URL?) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setLocalImage(with: url)
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

    private func configurePageControl() {
        self.pageControl.numberOfPages = self.viewModel?.imageIDs.count ?? 0
    }

    @IBAction func didTouchBackButton(_ sender: Any) {
        self.viewModel?.didTouchBackButton()
    }
}

extension DetailImageViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews.first
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = self.imageScrollView.contentOffset.x / self.imageScrollView.frame.size.width
        self.pageControl.currentPage = Int(round(value))
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.backButton.isHidden = true
        self.pageControl.isHidden = true
        if scrollView.zoomScale > 0.1 {
            if  let imageView = scrollView.subviews.first as? UIImageView,
                let image = imageView.image {
                let ratioWidth = imageView.frame.width / image.size.width
                let ratioHeight = imageView.frame.height / image.size.height
                let ratio = ratioWidth < ratioHeight ? ratioWidth:ratioHeight
                let newWidth = image.size.width * ratio
                let newHeight = image.size.height * ratio
                let leftInset = (newWidth * scrollView.zoomScale > imageView.frame.width ?
                           newWidth - imageView.frame.width :
                           scrollView.frame.width - scrollView.contentSize.width) / 2
                let topInset = (newHeight * scrollView.zoomScale > imageView.frame.height ?
                          newHeight - imageView.frame.height :
                          scrollView.frame.height - scrollView.contentSize.height) / 2
                scrollView.contentInset = UIEdgeInsets(
                    top: topInset, left: leftInset, bottom: topInset, right: leftInset
                )
            }
        }
    }

    func scrollViewDidEndZooming(
        _ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat
    ) {
        self.backButton.isHidden = false
        self.pageControl.isHidden = false
    }
}
