//
//  LandmarkAnnotationView.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/03.
//

import CoreLocation
import Foundation
import MapKit

class LandmarkAnnotationView: MKAnnotationView {
    static let identifier = "LandmarkAnnotationView"

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.image = UIImage(systemName: "pencil") // 수정 필요
        self.canShowCallout = true
        configure(annotation: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(annotation: MKAnnotation?) {
        guard let annotation = annotation as? LandmarkAnnotation,
              let imgURL = annotation.image
        else { return }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.image = UIImage(contentsOfFile: imgURL.path)
        self.leftCalloutAccessoryView = imageView
    }
}

class LandmarkAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: URL?

    init(landmark: Landmark) {
        self.coordinate = CLLocationCoordinate2D(
            latitude: landmark.latitude,
            longitude: landmark.longitude
        )
        self.image = landmark.image
        self.title = landmark.title
        self.subtitle = nil
    }
}
