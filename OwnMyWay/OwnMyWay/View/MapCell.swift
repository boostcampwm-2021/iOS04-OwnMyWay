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

    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureMapView(with: self.mapView)
    }

    func configure(with travel: Travel) {
        let landmarkAnnotations = travel.landmarks.map {
            LandmarkAnnotation.init(landmark: $0)
        }
        self.drawLandmarkAnnotations(
            mapView: self.mapView,
            annotations: landmarkAnnotations
        )
        self.moveRegion(
            mapView: self.mapView, annotations: landmarkAnnotations, animated: true
        )
    }
}