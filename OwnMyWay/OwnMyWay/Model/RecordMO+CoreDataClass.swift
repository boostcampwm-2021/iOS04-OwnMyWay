//
//  RecordMO+CoreDataClass.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//
//

import Foundation
import CoreData

@objc(RecordMO)
public class RecordMO: NSManagedObject {

    func toRecord() -> Record {
        return Record(
            uuid: self.uuid,
            content: self.content,
            date: self.date,
            latitude: self.latitude,
            longitude: self.longitude,
            photoURL: self.photoURL
        )
    }

    func fromRecord(record: Record) {
        self.uuid = record.uuid
        self.content = record.content
        self.date = record.date
        self.latitude = record.latitude ?? 0
        self.longitude = record.longitude ?? 0
        self.photoURL = record.photoURL
    }
}
