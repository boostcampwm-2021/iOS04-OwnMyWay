//
//  OMWMapView.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/22.
//

import MapKit
import UIKit

class OMWMapView: MKMapView, MapAvailable {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configure()
    }

    private func configure() {
        self.delegate = self
        self.configureMapView(with: self)
    }

    func configure(with travel: Travel, isMovingCamera: Bool) {
        let landmarkAnnotations = travel.landmarks.map {
            LandmarkAnnotation.init(landmark: $0)
        }
        let recordAnnotations = travel.records.map {
            RecordAnnotation.init(record: $0)
        }

        self.drawLandmarkAnnotations(
            mapView: self,
            annotations: landmarkAnnotations
        )
        self.drawRecordAnnotations(
            mapView: self,
            annotations: recordAnnotations
        )
        self.drawLocationPath(
            mapView: self,
            locations: travel.locations
        )

        if isMovingCamera {
            let locationAnnotations = travel.locations.map {
                LocationAnnotation.init(location: $0)
            }

            self.moveRegion(
                mapView: self,
                annotations: landmarkAnnotations + recordAnnotations + locationAnnotations,
                animated: true
            )
        }
        self.configureAccessibility()
    }

    func configureAccessibility() {
        self.isAccessibilityElement = false
    }

    class LocationAnnotation: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D

        init(location: Location) {
            self.coordinate = CLLocationCoordinate2D(
                latitude: location.latitude ?? 0,
                longitude: location.longitude ?? 0
            )
        }
    }
}

// MARK: - extension OMWMapView for MKMapViewDelegate

extension OMWMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is LandmarkAnnotation:
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: LandmarkAnnotationView.identifier,
                for: annotation
            ) as? LandmarkAnnotationView
            annotationView?.annotation = annotation
            return annotationView
        case is RecordAnnotation:
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: RecordAnnotationView.identifier,
                for: annotation
            ) as? RecordAnnotationView
            annotationView?.annotation = annotation
            return annotationView
        default:
            return nil
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
        let polylineRenderer = MKPolylineRenderer(polyline: polyline)
        polylineRenderer.strokeColor = .orange
        polylineRenderer.lineWidth = 5
        polylineRenderer.alpha = 1
        polylineRenderer.lineCap = .round
        return polylineRenderer
    }
}
