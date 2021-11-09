//
//  TravelRepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/02.
//

import CoreData
import UIKit

protocol TravelRepository {
    func fetchAllTravels() -> Result<[Travel], Error>
    func addTravel(title: String, startDate: Date, endDate: Date) -> Result<Travel, Error>
    func save(travel: Travel)
    func addLandmark(
        to travel: Travel,
        title: String?,
        image: URL?,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Landmark, Error>
    func addRecord(
        to travel: Travel,
        photoURL: URL?,
        content: String?,
        date: Date?,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Record, Error>
    func update(travel: Travel) -> Result<Travel, Error>
    func delete(travel: Travel)
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

    func fetchAllTravels() -> Result<[Travel], Error> {
        do {
            let travels = try context.fetch(TravelMO.fetchRequest())
            return .success(travels.map { $0.toTravel() })
        } catch let error {
            return .failure(error)
        }
    }

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

    func save(travel: Travel) {
        guard let travelEntity = NSEntityDescription.entity(forEntityName: "TravelMO", in: context),
              let landmarkEntity = NSEntityDescription.entity(
                forEntityName: "LandmarkMO", in: context
              )
        else { return }
        let travelMO = TravelMO(entity: travelEntity, insertInto: context)
        travelMO.setValue(travel.uuid, forKey: "uuid")
        travelMO.setValue(Travel.Section.reserved.index, forKey: "flag")
        travelMO.setValue(travel.title, forKey: "title")
        travelMO.setValue(travel.startDate, forKey: "startDate")
        travelMO.setValue(travel.endDate, forKey: "endDate")
        travel.landmarks.forEach {
            let landmark = $0
            let landmarkMO = LandmarkMO(entity: landmarkEntity, insertInto: context)
            landmarkMO.setValue(UUID(), forKey: "uuid")
            landmarkMO.setValue(landmark.title, forKey: "title")
            landmarkMO.setValue(landmark.image, forKey: "image")
            landmarkMO.setValue(landmark.latitude, forKey: "latitude")
            landmarkMO.setValue(landmark.longitude, forKey: "longitude")
            travelMO.addToLandmarks(landmarkMO)
        }
        try? context.save()
    }

    func addLandmark(
        to travel: Travel,
        title: String?,
        image: URL?,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Landmark, Error> {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else { return .failure(NSError.init()) }
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

    func addRecord(
        to travel: Travel,
        photoURL: URL?,
        content: String?,
        date: Date?,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Record, Error> {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else { return .failure(NSError.init()) }
        guard let entity = NSEntityDescription.entity(forEntityName: "RecordMO", in: context)
        else { return .failure(NSError.init()) }

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

    func update(travel: Travel) -> Result<Travel, Error> {
        guard let uuid = travel.uuid as CVarArg?
        else { return .failure(NSError.init()) }
        let request = TravelMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate

        guard let travels = try? context.fetch(request) as [TravelMO],
              let newTravel = travels.first
        else { return .failure(NSError.init()) }

        newTravel.flag = Int64(travel.flag)
        newTravel.title = travel.title
        newTravel.startDate = travel.startDate
        newTravel.endDate = travel.endDate

        do {
            try context.save()
            return .success(newTravel.toTravel())
        } catch let error {
            return .failure(error)
        }
    }

    func delete(travel: Travel) {
        guard let uuid = travel.uuid as CVarArg?
        else { return }
        let request = TravelMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let travels = try? context.fetch(request) as [TravelMO],
              let travel = travels.first
        else { return }

        context.delete(travel)

        do {
            try context.save()
        } catch {
            return
        }
    }

    private func findTravel(by uuid: UUID) -> TravelMO? {
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

}
