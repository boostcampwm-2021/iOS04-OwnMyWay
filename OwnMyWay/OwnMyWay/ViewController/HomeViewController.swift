//
//  ViewController.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/01.
//

import UIKit

class HomeViewController: UIViewController, Instantiable {

    var coordinator: HomeCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onbuttonpressed(_ sender: Any) {
        coordinator?.pushToCreateTravel()
    }
}
