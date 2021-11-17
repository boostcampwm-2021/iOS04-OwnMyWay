//
//  OutdatedMapCell.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/17.
//

import MapKit
import UIKit

class OutdatedMapCell: UICollectionViewCell, MapAvailable {
    static let identifier = "OutdatedMapCell"
    @IBOutlet weak var mapView: MKMapView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureMapView(with: self.mapView)
        self.mapView.delegate = self
    }

    func configure(with travel: Travel) {
        let landmarkAnnotations = travel.landmarks.map {
            LandmarkAnnotation.init(landmark: $0)
        }
        let recordAnnotations = travel.records.map {
            RecordAnnotation.init(record: $0)
        }
        let locationAnnotations = travel.locations.map {
            LocationAnnotation.init(location: $0)
        }

        self.drawLandmarkAnnotations(
            mapView: self.mapView,
            annotations: landmarkAnnotations
        )
        self.drawRecordAnnotations(
            mapView: self.mapView,
            annotations: recordAnnotations
        )
        self.drawLocationPath(
            mapView: self.mapView,
            locations: travel.locations
        )

        self.moveRegion(
            mapView: self.mapView,
            annotations: landmarkAnnotations + recordAnnotations + locationAnnotations,
            animated: true
        )
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

// MARK: - extension OutdatedMapCell for MKMapViewDelegate

extension OutdatedMapCell: MKMapViewDelegate {
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
