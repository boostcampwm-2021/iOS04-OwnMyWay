//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController, Instantiable {
    @IBOutlet private weak var cartView: UIView!
    private var bindContainerVC: ((UIView) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindContainerVC?(self.cartView)
    }

    func bind(closure: @escaping (UIView) -> Void) {
        self.bindContainerVC = closure
    }
}
