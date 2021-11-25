//
//  LandmarkMO+CoreDataProperties.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//
//

import CoreData
import Foundation

extension LandmarkMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LandmarkMO> {
        return NSFetchRequest<LandmarkMO>(entityName: "LandmarkMO")
    }

    @NSManaged public var image: URL?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var title: String?
    @NSManaged public var uuid: UUID?
    @NSManaged public var travel: TravelMO?

}

extension LandmarkMO : Identifiable {
    static func == (lhs: LandmarkMO, rhs: LandmarkMO) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}
