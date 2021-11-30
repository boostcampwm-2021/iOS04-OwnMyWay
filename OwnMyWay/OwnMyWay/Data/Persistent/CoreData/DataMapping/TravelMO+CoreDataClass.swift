//
//  TravelMO+CoreDataClass.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//
//
import CoreData
import Foundation

@objc(TravelMO)
final public class TravelMO: NSManagedObject {
    func toTravel() -> Travel {
        var result = Travel(
            uuid: self.uuid,
            flag: Int(self.flag),
            title: self.title,
            startDate: self.startDate,
            endDate: self.endDate,
            landmarks: [],
            records: [],
            locations: []
        )
        guard let landmarks = self.landmarks?.array as? [LandmarkMO],
              let records = self.records?.array as? [RecordMO],
              let locations = self.locations?.array as? [LocationMO]
        else { return result }

        result.landmarks = landmarks.map{ $0.toLandmark() }
        result.records = records.map{ $0.toRecord() }
        result.locations = locations.map { $0.toLocation() }
        return result
    }
    
    func fromTravel(travel: Travel) {
        self.uuid = travel.uuid
        self.flag = Int64(travel.flag)
        self.title = travel.title
        self.startDate = travel.startDate
        self.endDate = travel.endDate
        self.landmarks = NSOrderedSet(array: travel.landmarks)
        self.records = NSOrderedSet(array: travel.records)
        self.locations = NSOrderedSet(array: travel.locations)
    }
}
