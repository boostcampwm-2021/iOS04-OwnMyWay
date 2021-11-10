//
//  OutdatedTravelViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OutdatedTravelViewController: UIViewController, Instantiable {

    private var viewModel: OutdatedTravelViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bind(viewModel: OutdatedTravelViewModel) {
        self.viewModel = viewModel
    }
}
