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

        var zoomRect = MKMapRect.null
        points.forEach { point in
            let annotationPoint = MKMapPoint(
                CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
            )
            let pointRect = MKMapRect(
                x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1
            )
            zoomRect = zoomRect.union(pointRect)
        }

        mapView.setVisibleMapRect(
            zoomRect,
            edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
            animated: true
        )
    }

    func moveRegion(mapView: MKMapView, annotations: [MKAnnotation], animated: Bool) {
        guard !annotations.isEmpty else { return }

        var zoomRect = MKMapRect.null
        annotations.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(
                x: annotationPoint.x, y: annotationPoint.y, width: 0.1, height: 0.1
            )
            zoomRect = zoomRect.union(pointRect)
        }

        mapView.setVisibleMapRect(
            zoomRect,
            edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
            animated: true
        )
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
