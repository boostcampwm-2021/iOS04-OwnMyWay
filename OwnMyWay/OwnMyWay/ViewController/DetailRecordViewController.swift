//
//  DetailRecordViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

class DetailRecordViewController: UIViewController, Instantiable {

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
}
