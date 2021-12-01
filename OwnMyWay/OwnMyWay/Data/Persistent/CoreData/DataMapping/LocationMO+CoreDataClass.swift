//
//  LocationMO+CoreDataClass.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/11.
//
//
import CoreData
import Foundation

@objc(LocationMO)
final public class LocationMO: NSManagedObject {

    func toLocation() -> Location {
        return Location(latitude: self.latitude, longitude: self.longitude)
    }

    func fromLocation(location: Location) {
        self.latitude = location.latitude ?? 0
        self.longitude = location.longitude ?? 0
    }

}
