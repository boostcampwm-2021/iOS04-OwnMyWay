//
//  MapAvailable.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/04.
//

import MapKit
import Foundation

protocol Coordinatable {
    var latitude: Double { get set }
    var longitude: Double { get set }
}

protocol MapAvailable {
    func configureMapView(with mapView: MKMapView)
    func moveRegion(mapView: MKMapView, points: [Coordinatable], animated: Bool)
    func moveRegion(mapView: MKMapView, annotations: [MKAnnotation], animated: Bool)
    func drawRecordAnnotations(mapView: MKMapView, annotations: [MKAnnotation])
    func drawLandmarkAnnotations(mapView: MKMapView, annotations: [MKAnnotation])
}

extension MapAvailable {
    func configureMapView(with mapView: MKMapView) {
        mapView.register(
            LandmarkAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: LandmarkAnnotationView.identifier
        )

        mapView.setRegion(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 37.24800,
                    longitude: 127.07845
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.01,
                    longitudeDelta: 0.01
                )
            ),
            animated: false
        )
    }

    func moveRegion(mapView: MKMapView, points: [Coordinatable], animated: Bool) {
        guard !points.isEmpty else { return }

        var minLatitude: Double = 1000
        var maxLatitude: Double = -1000
        var minLongitude: Double = 1000
        var maxLongitude: Double = -1000

        points.forEach { point in
            minLatitude = min(minLatitude, point.latitude)
            maxLatitude = max(maxLatitude, point.latitude)
            minLongitude = min(minLongitude, point.longitude)
            maxLongitude = max(maxLongitude, point.longitude)
        }

        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = max(center.latitude - minLatitude, center.longitude - minLongitude)
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )

        mapView.setRegion(region, animated: animated)
    }

    func moveRegion(mapView: MKMapView, annotations: [MKAnnotation], animated: Bool) {
        guard !annotations.isEmpty else { return }

        var minLatitude: Double = 1000
        var maxLatitude: Double = -1000
        var minLongitude: Double = 1000
        var maxLongitude: Double = -1000

        annotations.forEach { annotation in
            minLatitude = min(minLatitude, annotation.coordinate.latitude)
            maxLatitude = max(maxLatitude, annotation.coordinate.latitude)
            minLongitude = min(minLongitude, annotation.coordinate.longitude)
            maxLongitude = max(maxLongitude, annotation.coordinate.longitude)
        }

        let centerLatitude = (minLatitude + maxLatitude) / 2
        let centerLongitude = (minLongitude + maxLongitude) / 2
        let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        let span = max(center.latitude - minLatitude, center.longitude - minLongitude)
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
        )

        mapView.setRegion(region, animated: animated)
    }

    func drawRecordAnnotations(mapView: MKMapView, annotations: [MKAnnotation]) {
        // 추후 구현
    }

    func drawLandmarkAnnotations(mapView: MKMapView, annotations: [MKAnnotation]) {
        let deleteSet = mapView.annotations.filter({ $0 is LandmarkAnnotation })
        mapView.removeAnnotations(deleteSet)
        mapView.addAnnotations(annotations)
    }
}
