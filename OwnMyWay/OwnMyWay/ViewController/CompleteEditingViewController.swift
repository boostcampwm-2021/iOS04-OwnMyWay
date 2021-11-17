//
//  CompleteEditingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import UIKit

class CompleteEditingViewController: UIViewController, Instantiable {

    private var viewModel: CompleteEditingViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    func bind(viewModel: CompleteEditingViewModel) {
        self.viewModel = viewModel
    }

    // FIXME: 구현 요망
}
