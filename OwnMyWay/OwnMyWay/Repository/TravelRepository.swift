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
    @discardableResult func addLandmark(
        to travel: Travel,
        uuid: UUID?,
        title: String?,
        image: URL?,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Landmark, Error>
    func addRecord(
        to travel: Travel,
        with record: Record
    ) -> Result<Travel, Error>
    @discardableResult func addLocation(
        to travel: Travel,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Location, Error>
    @discardableResult func update(travel: Travel) -> Result<Travel, Error>
    func updateRecord(at record: Record)
    func delete(travel: Travel)
    func deleteLandmark(at landmark: Landmark)
    func deleteRecord(at record: Record)
}

class CoreDataTravelRepository: TravelRepository {

    private lazy var context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        }
        let newContext = appDelegate.persistentContainer.newBackgroundContext()
        newContext.automaticallyMergesChangesFromParent = true
        newContext.retainsRegisteredObjects = true
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

    @discardableResult
    func addLandmark(
        to travel: Travel,
        uuid: UUID?,
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
        landmarkMO.setValue(uuid, forKey: "uuid")
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
        with record: Record
    ) -> Result<Travel, Error> {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else { return .failure(NSError.init()) }
        guard let entity = NSEntityDescription.entity(forEntityName: "RecordMO", in: context)
        else { return .failure(NSError.init()) }

        let recordMO = RecordMO(entity: entity, insertInto: context)
        recordMO.setValue(record.uuid, forKey: "uuid")
        recordMO.setValue(record.photoURLs, forKey: "photoURLs")
        recordMO.setValue(record.title, forKey: "title")
        recordMO.setValue(record.placeDescription, forKey: "placeDescription")
        recordMO.setValue(record.longitude, forKey: "longitude")
        recordMO.setValue(record.latitude, forKey: "latitude")
        recordMO.setValue(record.date, forKey: "date")
        recordMO.setValue(record.content, forKey: "content")
        travelMO.addToRecords(recordMO)

        do {
            try context.save()
            return .success(travelMO.toTravel())
        } catch let error {
            return .failure(error)
        }
    }

    @discardableResult
    func addLocation(
        to travel: Travel,
        latitude: Double?,
        longitude: Double?
    ) -> Result<Location, Error> {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else { return .failure(NSError.init()) }
        guard let entity = NSEntityDescription.entity(forEntityName: "LocationMO", in: context)
        else { return .failure(NSError.init()) }

        let locationMO = LocationMO(entity: entity, insertInto: context)
        locationMO.setValue(latitude, forKey: "latitude")
        locationMO.setValue(longitude, forKey: "longitude")
        travelMO.addToLocations(locationMO)

        do {
            try context.save()
            return .success(locationMO.toLocation())
        } catch let error {
            return .failure(error)
        }
    }

    @discardableResult
    func update(travel: Travel) -> Result<Travel, Error> {
        guard let uuid = travel.uuid as CVarArg?
        else { return .failure(NSError.init()) }

        let request = TravelMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate

        guard let travels = try? context.fetch(request) as [TravelMO],
              let newTravel = travels.first
        else { return .failure(NSError.init()) }

        newTravel.uuid = travel.uuid
        newTravel.flag = Int64(travel.flag)
        newTravel.title = travel.title
        newTravel.startDate = travel.startDate
        newTravel.endDate = travel.endDate
        // FIXME: 세개 다 업데이트해줘야함!!
//        newTravel.landmarks = NSOrderedSet(array: travel.landmarks)
//        newTravel.locations = NSOrderedSet(array: travel.locations)
//        newTravel.records = NSOrderedSet(array: travel.records)

        do {
            try context.save()
            return .success(newTravel.toTravel())
        } catch let error {
            return .failure(error)
        }
    }

    func updateRecord(at record: Record) {
        guard let uuid = record.uuid as CVarArg?
        else { return }

        let request = RecordMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let records = try? context.fetch(request) as [RecordMO],
              let newRecord = records.first
        else { return }

        newRecord.title = record.title
        newRecord.date = record.date
        newRecord.latitude = record.latitude ?? 0
        newRecord.longitude = record.longitude ?? 0
        newRecord.placeDescription = record.placeDescription
        newRecord.photoURLs = record.photoURLs
        newRecord.content = record.content

        do {
            try context.save()
        } catch {
            return
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

    func deleteLandmark(at landmark: Landmark) {
        guard let uuid = landmark.uuid as CVarArg?
        else { return }

        let request = LandmarkMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let landmarks = try? context.fetch(request) as [LandmarkMO],
              let landmark = landmarks.first
        else { return }
        context.delete(landmark)
        do {
            try context.save()
        } catch {
            return
        }
    }

    func deleteRecord(at record: Record) {
        guard let uuid = record.uuid as CVarArg?
        else { return }

        let request = RecordMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let records = try? context.fetch(request) as [RecordMO],
              let record = records.first
        else { return }
        context.delete(record)
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
