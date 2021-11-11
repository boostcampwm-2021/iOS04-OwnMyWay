//
//  LocationMO+CoreDataProperties.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/11.
//
//

import Foundation
import CoreData

extension LocationMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationMO> {
        return NSFetchRequest<LocationMO>(entityName: "LocationMO")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var travel: TravelMO?

}

extension LocationMO: Identifiable {

}
