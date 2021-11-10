//
//  OngoingViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import UIKit

class OngoingViewController: UIViewController, Instantiable {

    private var viewModel: OngoingViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bind(viewModel: OngoingViewModel) {
        self.viewModel = viewModel
    }

    @IBAction func didTouchAddRecordButton(_ sender: UIButton) {
        self.viewModel?.didTouchAddRecordButton()
    }

    @IBAction func didTouchFinishButton(_ sender: UIButton) {
        self.viewModel?.didTouchFinishButton()
    }

}
