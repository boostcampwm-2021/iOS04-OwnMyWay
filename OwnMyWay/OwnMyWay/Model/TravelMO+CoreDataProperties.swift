//
//  TravelMO+CoreDataProperties.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//
//

import Foundation
import CoreData


extension TravelMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TravelMO> {
        return NSFetchRequest<TravelMO>(entityName: "TravelMO")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var flag: Int64
    @NSManaged public var uuid: UUID?
    @NSManaged public var landmarks: NSSet?
    @NSManaged public var records: NSSet?

}

// MARK: Generated accessors for landmarks
extension TravelMO {

    @objc(addLandmarksObject:)
    @NSManaged public func addToLandmarks(_ value: LandmarkMO)

    @objc(removeLandmarksObject:)
    @NSManaged public func removeFromLandmarks(_ value: LandmarkMO)

    @objc(addLandmarks:)
    @NSManaged public func addToLandmarks(_ values: NSSet)

    @objc(removeLandmarks:)
    @NSManaged public func removeFromLandmarks(_ values: NSSet)

}

// MARK: Generated accessors for records
extension TravelMO {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: RecordMO)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: RecordMO)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension TravelMO : Identifiable {

}
