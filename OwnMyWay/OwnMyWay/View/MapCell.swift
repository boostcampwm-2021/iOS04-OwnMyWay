//
//  MapCell.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/10.
//

import MapKit
import UIKit

class MapCell: UICollectionViewCell, MapAvailable {
    static let identifier = "MapCell"

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureMapView(with: self.mapView)
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true

        let image = UIImage(systemName: "paperplane.circle")
        let normalImage = image?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        let selectedImage = image?.withTintColor(.systemGreen, renderingMode: .alwaysOriginal)
        self.trackingButton.setImage(normalImage, for: .normal)
        self.trackingButton.setImage(selectedImage, for: .selected)
    }

    func configure(with travel: Travel) {
        let landmarkAnnotations = travel.landmarks.map {
            LandmarkAnnotation.init(landmark: $0)
        }
        let recordAnnotations = travel.records.map {
            RecordAnnotation.init(record: $0)
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

        if LocationManager.shared.authorizationStatus == .authorizedAlways {
            switch LocationManager.shared.isUpdatingLocation {
            case true:
                self.trackingButton.isSelected = true
            case false:
                self.trackingButton.isSelected = false
            }
        }
    }

    @IBAction func didTouchTrackingButton(_ sender: Any) {
        if LocationManager.shared.authorizationStatus == .authorizedAlways {
            self.trackingButton.isSelected.toggle()
            switch LocationManager.shared.isUpdatingLocation {
            case true:
                LocationManager.shared.stopUpdatingLocation()
            case false:
                self.mapView.setUserTrackingMode(.follow, animated: true)
                LocationManager.shared.startUpdatingLocation()
            }

        } else {
            let alert = UIAlertController(
                title: "권한 설정이 필요합니다.",
                message: "Setting -> OnwMyWay -> 위치 -> 항상 허용",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "이동", style: .default) { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString)
                else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            alert.addAction(action)

            guard let lastVC = UIApplication.shared.windows.first?.rootViewController
            else { return }
            lastVC.children.last?.present(alert, animated: true)
        }
    }

    @IBAction func didTouchLocationButton(_ sender: Any) {
        self.mapView.setUserTrackingMode(.follow, animated: true)
    }
}

// MARK: - extension MapCell for MKMapViewDelegate

extension MapCell: MKMapViewDelegate {
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
