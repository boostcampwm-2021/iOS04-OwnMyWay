//
//  Instantiable.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import UIKit

protocol Instantiable {
    static func instantiate(storyboardName: String) -> Self
}

extension Instantiable where Self: UIViewController {
    static func instantiate(storyboardName: String) -> Self {
        let vcName = String(describing: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let vcInstance = storyboard.instantiateViewController(withIdentifier: vcName) as? Self
        else {
            return Self()
        }
        return vcInstance
    }
}
