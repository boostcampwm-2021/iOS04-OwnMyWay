//
//  LocationManager.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/15.
//

import CoreLocation

final class LocationManager: CLLocationManager {

    private var repository: CoreDataTravelRepository?

    private var travel: Travel?
    private(set) var isUpdatingLocation = false

    static let shared = LocationManager()

    private override init() {
        super.init()
        self.configureLocationManager()
    }

    override func startUpdatingLocation() {
        super.startUpdatingLocation()
        self.isUpdatingLocation = true
    }

    override func stopUpdatingLocation() {
        super.stopUpdatingLocation()
        self.isUpdatingLocation = false
    }

    func bind(repository: CoreDataTravelRepository) {
        self.repository = repository
    }

    func currentTravel(to travel: Travel?) {
        self.travel = travel
    }

    private func configureLocationManager() {
        self.delegate = self
        self.desiredAccuracy = kCLLocationAccuracyBest
        self.distanceFilter = 10
        self.allowsBackgroundLocationUpdates = true
        self.pausesLocationUpdatesAutomatically = false
        self.showsBackgroundLocationIndicator = true
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last
        guard let latitude = lastLocation?.coordinate.latitude,
              let longitude = lastLocation?.coordinate.longitude,
              let travel = self.travel
        else { return }
        self.repository?.addLocation(to: travel, latitude: latitude, longitude: longitude) { _ in }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.fetchAuthorizationStatus() {
        case .restricted, .denied:
            self.stopUpdatingLocation()
        default:
            break
        }
    }
}
