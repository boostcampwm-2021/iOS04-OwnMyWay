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
            let imageView = UIImageView()
            imageView.setImage(with: url)
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.resize()
            self.imageStackView.addArrangedSubview(imageView)
        }
        // Do any additional setup after loading the view.
    }

    func bind(viewModel: DetailImageViewModel) {
        self.viewModel = viewModel
    }
}

extension DetailImageViewController: UIScrollViewDelegate {

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.isPagingEnabled = scrollView.zoomScale == 1.0
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageStackView
    }
}
