//
//  TravelMO+CoreDataProperties.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/11.
//
//
import CoreData
import Foundation

extension TravelMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TravelMO> {
        return NSFetchRequest<TravelMO>(entityName: "TravelMO")
    }

    @NSManaged public var endDate: Date?
    @NSManaged public var flag: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var landmarks: NSOrderedSet?
    @NSManaged public var records: NSOrderedSet?
    @NSManaged public var locations: NSOrderedSet?

}

// MARK: Generated accessors for landmarks
extension TravelMO {

    @objc(insertObject:inLandmarksAtIndex:)
    @NSManaged public func insertIntoLandmarks(_ value: LandmarkMO, at idx: Int)

    @objc(removeObjectFromLandmarksAtIndex:)
    @NSManaged public func removeFromLandmarks(at idx: Int)

    @objc(insertLandmarks:atIndexes:)
    @NSManaged public func insertIntoLandmarks(_ values: [LandmarkMO], at indexes: NSIndexSet)

    @objc(removeLandmarksAtIndexes:)
    @NSManaged public func removeFromLandmarks(at indexes: NSIndexSet)

    @objc(replaceObjectInLandmarksAtIndex:withObject:)
    @NSManaged public func replaceLandmarks(at idx: Int, with value: LandmarkMO)

    @objc(replaceLandmarksAtIndexes:withLandmarks:)
    @NSManaged public func replaceLandmarks(at indexes: NSIndexSet, with values: [LandmarkMO])

    @objc(addLandmarksObject:)
    @NSManaged public func addToLandmarks(_ value: LandmarkMO)

    @objc(removeLandmarksObject:)
    @NSManaged public func removeFromLandmarks(_ value: LandmarkMO)

    @objc(addLandmarks:)
    @NSManaged public func addToLandmarks(_ values: NSOrderedSet)

    @objc(removeLandmarks:)
    @NSManaged public func removeFromLandmarks(_ values: NSOrderedSet)

}

// MARK: Generated accessors for records
extension TravelMO {

    @objc(insertObject:inRecordsAtIndex:)
    @NSManaged public func insertIntoRecords(_ value: RecordMO, at idx: Int)

    @objc(removeObjectFromRecordsAtIndex:)
    @NSManaged public func removeFromRecords(at idx: Int)

    @objc(insertRecords:atIndexes:)
    @NSManaged public func insertIntoRecords(_ values: [RecordMO], at indexes: NSIndexSet)

    @objc(removeRecordsAtIndexes:)
    @NSManaged public func removeFromRecords(at indexes: NSIndexSet)

    @objc(replaceObjectInRecordsAtIndex:withObject:)
    @NSManaged public func replaceRecords(at idx: Int, with value: RecordMO)

    @objc(replaceRecordsAtIndexes:withRecords:)
    @NSManaged public func replaceRecords(at indexes: NSIndexSet, with values: [RecordMO])

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: RecordMO)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: RecordMO)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSOrderedSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSOrderedSet)

}

// MARK: Generated accessors for locations
extension TravelMO {

    @objc(insertObject:inLocationsAtIndex:)
    @NSManaged public func insertIntoLocations(_ value: LocationMO, at idx: Int)

    @objc(removeObjectFromLocationsAtIndex:)
    @NSManaged public func removeFromLocations(at idx: Int)

    @objc(insertLocations:atIndexes:)
    @NSManaged public func insertIntoLocations(_ values: [LocationMO], at indexes: NSIndexSet)

    @objc(removeLocationsAtIndexes:)
    @NSManaged public func removeFromLocations(at indexes: NSIndexSet)

    @objc(replaceObjectInLocationsAtIndex:withObject:)
    @NSManaged public func replaceLocations(at idx: Int, with value: LocationMO)

    @objc(replaceLocationsAtIndexes:withLocations:)
    @NSManaged public func replaceLocations(at indexes: NSIndexSet, with values: [LocationMO])

    @objc(addLocationsObject:)
    @NSManaged public func addToLocations(_ value: LocationMO)

    @objc(removeLocationsObject:)
    @NSManaged public func removeFromLocations(_ value: LocationMO)

    @objc(addLocations:)
    @NSManaged public func addToLocations(_ values: NSOrderedSet)

    @objc(removeLocations:)
    @NSManaged public func removeFromLocations(_ values: NSOrderedSet)

}

extension TravelMO : Identifiable {

}
