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
        self.configureNavigation()
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }

    private func configureNavigation() {
        self.navigationItem.title = "게시물 작성"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonAction)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(submitButtonAction)
        )
    }

    @objc private func backButtonAction() {
        self.viewModel?.didTouchBackButton()
    }

    @objc private func submitButtonAction() {
        self.viewModel?.didTouchSubmitButton()
    }

}
