//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController, Instantiable {
    @IBOutlet weak var cartView: UIView!
    var closure: ((UIView) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.closure?(self.cartView)
    }

    func bind(closure: @escaping (UIView) -> Void) {
        self.closure = closure
    }
}
