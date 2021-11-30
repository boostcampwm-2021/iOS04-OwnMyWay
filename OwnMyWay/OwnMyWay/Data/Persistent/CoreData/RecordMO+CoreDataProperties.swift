//
//  RecordMO+CoreDataProperties.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/25.
//
//
import Foundation
import CoreData


extension RecordMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordMO> {
        return NSFetchRequest<RecordMO>(entityName: "RecordMO")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: Date?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photoIDs: [String]?
    @NSManaged public var placeDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var travel: TravelMO?

}

extension RecordMO : Identifiable {

}
