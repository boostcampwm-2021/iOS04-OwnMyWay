//
//  TravelRepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/02.
//

import Foundation
import CoreData
import UIKit

protocol TravelRepository {

}

class CoreDataTravelRepository: TravelRepository {

    private lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObjectContext.init(.privateQueue)
        }
        let newContext = appDelegate.persistentContainer.newBackgroundContext()
        newContext.automaticallyMergesChangesFromParent = true
        return newContext
    }()

    func addTravel(title: String, startDate: Date, endDate: Date) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "Travel", in: context) else {
            return
        }
        let travel = Travel(entity: entity, insertInto: context)
        travel.setValue(title, forKey: "title")
        travel.setValue(startDate, forKey: "startDate")
        travel.setValue(endDate, forKey: "endDate")
        try context.save()
    }

    func fetchAll() throws -> [Travel] {
        let travels = try context.fetch(Travel.fetchRequest())
        return travels
    }

    func findTravelById(objectID: NSManagedObjectID) -> Travel? {
        guard let travel = context.object(with: objectID) as? Travel else {
            return nil
        }
        return travel
    }

}
