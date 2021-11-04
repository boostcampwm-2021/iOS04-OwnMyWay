//
//  TravelCartViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/03.
//

import UIKit

class AddLandmarkViewController: UIViewController, Instantiable {
    @IBOutlet weak var cartView: UIView!
    @IBOutlet weak var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let cartVC = LandmarkCartViewController.instantiate(storyboardName: "LandmarkCart")
        addChild(cartVC)
        self.cartView.addSubview(cartVC.view)
        cartVC.view.translatesAutoresizingMaskIntoConstraints = false
        cartVC.view.topAnchor.constraint(equalTo: cartView.topAnchor).isActive = true
        cartVC.view.leadingAnchor.constraint(equalTo: cartView.leadingAnchor).isActive = true
        cartVC.view.trailingAnchor.constraint(equalTo: cartView.trailingAnchor).isActive = true
        cartVC.view.bottomAnchor.constraint(equalTo: cartView.bottomAnchor).isActive = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let mapViewHeight: CGFloat = UIScreen.main.bounds.width
        let collectionViewHeight: CGFloat = 220
        contentView.heightAnchor
            .constraint(equalToConstant: mapViewHeight + collectionViewHeight)
            .isActive = true
        view.layoutIfNeeded()
    }

}
