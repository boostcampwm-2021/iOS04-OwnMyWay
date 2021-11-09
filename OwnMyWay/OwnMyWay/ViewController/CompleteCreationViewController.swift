//
//  CompleteCreationViewController.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import UIKit

class CompleteCreationViewController: UIViewController, Instantiable {

    private var viewModel: CompleteCreationViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bind(viewModel: CompleteCreationViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func didTouchCompleteButton(_ sender: UIButton) {
        self.viewModel?.didTouchCompleteButton()
    }

}
