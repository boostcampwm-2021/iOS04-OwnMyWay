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
    func drawLocationPath(mapView: MKMapView, locations: [Location])
}

extension MapAvailable {
    func configureMapView(with mapView: MKMapView) {
        mapView.register(
            LandmarkAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: LandmarkAnnotationView.identifier
        )
        mapView.register(
            RecordAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: RecordAnnotationView.identifier
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
        let deleteSet = mapView.annotations.filter({ $0 is RecordAnnotation })
        mapView.removeAnnotations(deleteSet)
        mapView.addAnnotations(annotations)
    }

    func drawLandmarkAnnotations(mapView: MKMapView, annotations: [MKAnnotation]) {
        let deleteSet = mapView.annotations.filter({ $0 is LandmarkAnnotation })
        mapView.removeAnnotations(deleteSet)
        mapView.addAnnotations(annotations)
    }

    func drawLocationPath(mapView: MKMapView, locations: [Location]) {
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        let coordinates = locations.map {
            CLLocationCoordinate2D(
                latitude: $0.latitude ?? 0, longitude: $0.longitude ?? 0
            )
        }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline, level: .aboveRoads)
        mapView.layoutIfNeeded()
    }

}
