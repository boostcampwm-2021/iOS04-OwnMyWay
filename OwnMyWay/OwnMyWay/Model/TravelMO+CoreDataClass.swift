//
//  TravelMO+CoreDataClass.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//
//

import Foundation
import CoreData

@objc(TravelMO)
public class TravelMO: NSManagedObject {
    func toTravel() -> Travel {
        var result = Travel(
            uuid: self.uuid,
            flag: Int(self.flag),
            title: self.title,
            startDate: self.startDate,
            endDate: self.endDate,
            landmarks: [],
            records: []
        )
        guard let landmarks = self.landmarks?.array as? [LandmarkMO],
              let records = self.records?.array as? [RecordMO]
        else { return result }

        result.landmarks = landmarks.map{ $0.toLandmark() }
        result.records = records.map{ $0.toRecord() }
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
    }
}
