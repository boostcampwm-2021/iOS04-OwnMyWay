//
//  RecordMO+CoreDataClass.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/15.
//
//

import CoreData
import Foundation

@objc(RecordMO)
public class RecordMO: NSManagedObject {

    func toRecord() -> Record {
        return Record(
            uuid: self.uuid, title: self.title, content: self.content, date: self.date,
            latitude: self.latitude, longitude: self.longitude,
            photoURLs: self.photoURLs, placeDescription: self.placeDescription
        )
    }

    func fromRecord(record: Record) {
        self.uuid = record.uuid
        self.title = record.title
        self.content = record.content
        self.date = record.date
        self.latitude = record.latitude ?? 0
        self.longitude = record.longitude ?? 0
        self.photoURLs = record.photoURLs
        self.placeDescription = record.placeDescription
    }

}
