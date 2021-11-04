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
        return Travel(
            uuid: self.uuid,
            flag: Int(self.flag),
            title: self.title,
            startDate: self.startDate,
            endDate: self.endDate,
            landmarks: self.landmarks?.allObjects as? [Landmark] ?? [],
            records: self.records?.allObjects as? [Record] ?? []
        )
    }
    
    func fromTravel(travel: Travel) {
        self.uuid = travel.uuid
        self.flag = Int64(travel.flag)
        self.title = travel.title
        self.startDate = travel.startDate
        self.endDate = travel.endDate
        self.landmarks = NSSet(array: travel.landmarks)
        self.records = NSSet(array: travel.records)
    }
}
