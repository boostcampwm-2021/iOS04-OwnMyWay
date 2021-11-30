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
final public class RecordMO: NSManagedObject {

    func toRecord() -> Record {
        return Record(
            uuid: self.uuid, title: self.title, content: self.content, date: self.date,
            latitude: self.latitude, longitude: self.longitude,
            photoIDs: self.photoIDs, placeDescription: self.placeDescription
        )
    }

    func fromRecord(record: Record) {
        self.uuid = record.uuid
        self.title = record.title
        self.content = record.content
        self.date = record.date
        self.latitude = record.latitude ?? 0
        self.longitude = record.longitude ?? 0
        self.photoIDs = record.photoIDs
        self.placeDescription = record.placeDescription
    }

}
