//
//  MapCell.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/10.
//

import MapKit
import UIKit

protocol ButtonDelegate: AnyObject {
    func didTouchTrackingButton()
}

class MapCell: UICollectionViewCell, MapAvailable {
    static let identifier = "MapCell"

    @IBOutlet weak var mapView: MKMapView!
    private weak var buttonDelegate: ButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureMapView(with: self.mapView)
    }

    func configure(
        with travel: Travel, mapDelegate: MKMapViewDelegate, buttonDelegate: ButtonDelegate
    ) {
        self.mapView.delegate = mapDelegate
        self.buttonDelegate = buttonDelegate

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
    }

    @IBAction func didTouchTrackingButton(_ sender: Any) {
        self.buttonDelegate?.didTouchTrackingButton()
    }
}
