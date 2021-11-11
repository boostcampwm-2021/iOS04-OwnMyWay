//
//  AddRecordViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class AddRecordViewController: UIViewController, Instantiable {

    private var viewModel: AddRecordViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }
}
