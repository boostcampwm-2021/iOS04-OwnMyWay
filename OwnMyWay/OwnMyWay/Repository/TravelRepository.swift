//
//  TravelRepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/02.
//

import CoreData
import UIKit

protocol TravelRepository {
    func addTravel(title: String, startDate: Date, endDate: Date) -> Result<Travel, Error>
    func fetchAll() -> Result<[Travel], Error>
    func findTravel(by objectID: NSManagedObjectID) -> Travel?
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

    func addTravel(title: String, startDate: Date, endDate: Date) -> Result<Travel, Error> {
        guard let entity = NSEntityDescription.entity(forEntityName: "Travel", in: context) else {
            return .failure(NSError.init())
        }
        let travel = Travel(entity: entity, insertInto: context)
        travel.setValue(title, forKey: "title")
        travel.setValue(startDate, forKey: "startDate")
        travel.setValue(endDate, forKey: "endDate")
        do {
            try context.save()
            return .success(travel)
        } catch let error {
            return .failure(error)
        }
    }

    func fetchAll() -> Result<[Travel], Error> {
        do {
            let travels = try context.fetch(Travel.fetchRequest())
            return .success(travels)
        } catch let error {
            return .failure(error)
        }
    }

    func findTravel(by objectID: NSManagedObjectID) -> Travel? {
        guard let travel = context.object(with: objectID) as? Travel else {
            return nil
        }
        return travel
    }

}
