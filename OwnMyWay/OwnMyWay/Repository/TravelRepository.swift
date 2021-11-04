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
    func addRecord(to travel: Travel,
                   photoURL: URL?,
                   content: String?,
                   date: Date?,
                   latitude: Double?,
                   longitude: Double?) -> Result<Record, Error>
    func addLandmark(to travel: Travel,
                     title: String?,
                     image: URL?,
                     latitude: Double?,
                     longitude: Double?) -> Result<Landmark, Error>
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
        guard let entity = NSEntityDescription.entity(forEntityName: "TravelMO", in: context) else {
            return .failure(NSError.init())
        }
        let travel = TravelMO(entity: entity, insertInto: context)
        travel.setValue(UUID(), forKey: "uuid")
        travel.setValue(0, forKey: "flag")
        travel.setValue(title, forKey: "title")
        travel.setValue(startDate, forKey: "startDate")
        travel.setValue(endDate, forKey: "endDate")
        do {
            try context.save()
            return .success(travel.toTravel())
        } catch let error {
            return .failure(error)
        }
    }

    func fetchAll() -> Result<[Travel], Error> {
        do {
            let travels = try context.fetch(TravelMO.fetchRequest())
            return .success(travels.map{ $0.toTravel() })
        } catch let error {
            return .failure(error)
        }
    }

    func findTravel(by uuid: UUID) -> TravelMO? {
        let request = TravelMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        request.predicate = predicate
        do {
            let travels = try context.fetch(request)
            return travels.first ?? nil
        } catch {
            return nil
        }
    }

    func addRecord(to travel: Travel,
                   photoURL: URL?,
                   content: String?,
                   date: Date?,
                   latitude: Double?,
                   longitude: Double?) -> Result<Record, Error> {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID()) else {
            return .failure(NSError.init())
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "RecordMO", in: context) else {
            return .failure(NSError.init())
        }
        let recordMO = RecordMO(entity: entity, insertInto: context)
        recordMO.setValue(UUID(), forKey: "uuid")
        recordMO.setValue(photoURL, forKey: "photoURL")
        recordMO.setValue(content, forKey: "content")
        recordMO.setValue(date, forKey: "date")
        recordMO.setValue(latitude, forKey: "latitude")
        recordMO.setValue(longitude, forKey: "longitude")
        travelMO.addToRecords(recordMO)
        do {
            try context.save()
            return .success(recordMO.toRecord())
        } catch let error {
            return .failure(error)
        }
    }

    func addLandmark(to travel: Travel,
                     title: String?,
                     image: URL?,
                     latitude: Double?,
                     longitude: Double?) -> Result<Landmark, Error> {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID()) else {
            return .failure(NSError.init())
        }
        guard let entity = NSEntityDescription.entity(forEntityName: "LandmarkMO", in: context)
        else { return .failure(NSError.init()) }
        let landmarkMO = LandmarkMO(entity: entity, insertInto: context)
        landmarkMO.setValue(UUID(), forKey: "uuid")
        landmarkMO.setValue(title, forKey: "title")
        landmarkMO.setValue(image, forKey: "image")
        landmarkMO.setValue(latitude, forKey: "latitude")
        landmarkMO.setValue(longitude, forKey: "longitude")
        travelMO.addToLandmarks(landmarkMO)
        do {
            try context.save()
            return .success(landmarkMO.toLandmark())
        } catch let error {
            return .failure(error)
        }
    }

}
