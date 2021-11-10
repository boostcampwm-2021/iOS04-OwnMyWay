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

    override var annotation: MKAnnotation? { didSet { configureDetailView() } }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    func configure() {
        self.canShowCallout = true
        self.image = UIImage(named: "LandmarkPin")
        configureDetailView()
    }

    func configureDetailView() {
        guard let annotation = annotation as? LandmarkAnnotation else { return }

        let rect = CGRect(origin: .zero, size: CGSize(width: 300, height: 200))

        let detailView = UIView()
        let imageView = UIImageView(frame: rect)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setImage(with: annotation.image)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        detailView.addSubview(imageView)

        detailCalloutAccessoryView = detailView
        NSLayoutConstraint.activate([
            detailView.widthAnchor.constraint(equalToConstant: rect.width),
            detailView.heightAnchor.constraint(equalToConstant: rect.height)
        ])
    }
}

class LandmarkAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: URL?

    init(landmark: Landmark) {
        self.coordinate = CLLocationCoordinate2D(
            latitude: landmark.latitude ?? 0,
            longitude: landmark.longitude ?? 0
        )
        self.image = landmark.image
        self.title = landmark.title
        self.subtitle = nil
    }
}
