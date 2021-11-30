//
//  CLLocationManager+.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/18.
//

import Foundation
import CoreLocation

extension CLLocationManager {
    func fetchAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return self.authorizationStatus
        } else {
            return LocationManager.authorizationStatus()
        }
    }
}
