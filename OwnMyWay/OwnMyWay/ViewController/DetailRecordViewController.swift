//
//  DetailRecordViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import UIKit

class DetailRecordViewController: UIViewController, Instantiable {

    private var viewModel: DetailRecordViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.viewModel?.record.content
    }

    func bind(viewModel: DetailRecordViewModel) {
        self.viewModel = viewModel
    }
}
