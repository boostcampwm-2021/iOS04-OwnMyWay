//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController {
    @IBOutlet weak var cartView: UIView!

    static func instantiate() -> AddLandmarkViewController {
        let storyboard = UIStoryboard(name: "AddLandmark", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddLandmarkViewController")
        guard let viewController = viewController as? Self
        else { return AddLandmarkViewController() }
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cartVC = LandmarkCartViewController.instantiate()
        addChild(cartVC)
        self.cartView.addSubview(cartVC.view)
        cartVC.view.translatesAutoresizingMaskIntoConstraints = false
        cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
        cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
        cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
        cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
    }
}
