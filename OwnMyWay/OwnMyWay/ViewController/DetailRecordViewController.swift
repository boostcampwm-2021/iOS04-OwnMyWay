//
//  DetailRecordViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

class DetailRecordViewController: UIViewController, Instantiable {

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageStackView: UIStackView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    private var viewModel: DetailRecordViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.viewModel?.record.content
    }

    func bind(viewModel: DetailRecordViewModel) {
        self.viewModel = viewModel
    }
    
    // FIXME: ViewModel record에 바인딩?
    private func configurePageControl() {
        guard let numberOfphotos = self.viewModel?.record.photoURLs?.count else { return }
        self.pageControl.numberOfPages = numberOfphotos
    }
    
    private func configurePageControlSelectedPage(currentPage: Int) {
        self.pageControl.currentPage = currentPage
    }
}

// MARK: - UIScollViewDelegate
extension DetailRecordViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(round(self.imageScrollView.contentOffset.x / self.imageScrollView.frame.size.width))
        self.configurePageControlSelectedPage(currentPage: currentPage)
    }
}
