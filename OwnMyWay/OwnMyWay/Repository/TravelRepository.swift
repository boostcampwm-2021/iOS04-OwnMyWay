//
//  TravelRepository.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/02.
//

import CoreData

protocol TravelRepository {
    func fetchAllTravels(completion: @escaping (Result<[Travel], Error>) -> Void)
    func addTravel(
        title: String, startDate: Date, endDate: Date,
        completion: @escaping (Result<Travel, Error>) -> Void
    )
    func save(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
    func addLandmark(
        to travel: Travel, uuid: UUID?, title: String?,
        image: URL?, latitude: Double?, longitude: Double?,
        completion: @escaping (Result<Landmark, Error>) -> Void
    )
    func addRecord(
        to travel: Travel, with record: Record,
        completion: @escaping (Result<Travel, Error>) -> Void
    )
    func addLocation(
        to travel: Travel, latitude: Double?, longitude: Double?,
        completion: @escaping (Result<Location, Error>) -> Void
    )
    func update(travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void)
    func updateRecord(at record: Record, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteLandmark(at landmark: Landmark, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteRecord(at record: Record, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol ContextAccessable {
    func fetchContext() -> NSManagedObjectContext
}

final class CoreDataTravelRepository: TravelRepository {

    private var contextFetcher: ContextAccessable

    private lazy var context: NSManagedObjectContext = {
        return self.contextFetcher.fetchContext()
    }()

    init(contextFetcher: ContextAccessable) {
        self.contextFetcher = contextFetcher
    }

    func fetchAllTravels(completion: @escaping (Result<[Travel], Error>) -> Void) {
        do {
            let travels = try context.fetch(TravelMO.fetchRequest())
            completion(.success(travels.map { $0.toTravel() }))
        } catch {
            completion(.failure(RepositoryError.saveError))
        }
    }

    func addTravel(
        title: String, startDate: Date, endDate: Date,
        completion: @escaping (Result<Travel, Error>) -> Void
    ) {
        guard let entity = NSEntityDescription.entity(forEntityName: "TravelMO", in: context) else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        let travel = TravelMO(entity: entity, insertInto: context)
        travel.setValue(UUID(), forKey: "uuid")
        travel.setValue(0, forKey: "flag")
        travel.setValue(title, forKey: "title")
        travel.setValue(startDate, forKey: "startDate")
        travel.setValue(endDate, forKey: "endDate")
        do {
            try context.save()
            completion(.success(travel.toTravel()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func save(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let travelEntity = NSEntityDescription.entity(forEntityName: "TravelMO", in: context),
              let landmarkEntity = NSEntityDescription.entity(
                forEntityName: "LandmarkMO", in: context
              )
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
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
        do {
            try context.save()
            completion(.success(()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func addLandmark(
        to travel: Travel, uuid: UUID?, title: String?,
        image: URL?, latitude: Double?, longitude: Double?,
        completion: @escaping (Result<Landmark, Error>) -> Void
    ) {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "LandmarkMO", in: context)
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        let landmarkMO = LandmarkMO(entity: entity, insertInto: context)
        landmarkMO.setValue(uuid, forKey: "uuid")
        landmarkMO.setValue(title, forKey: "title")
        landmarkMO.setValue(image, forKey: "image")
        landmarkMO.setValue(latitude, forKey: "latitude")
        landmarkMO.setValue(longitude, forKey: "longitude")
        travelMO.addToLandmarks(landmarkMO)

        do {
            try context.save()
            completion(.success(landmarkMO.toLandmark()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func addRecord(
        to travel: Travel, with record: Record,
        completion: @escaping (Result<Travel, Error>) -> Void
    ) {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "RecordMO", in: context)
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        let recordMO = RecordMO(entity: entity, insertInto: context)
        recordMO.setValue(record.uuid, forKey: "uuid")
        recordMO.setValue(record.photoIDs, forKey: "photoIDs")
        recordMO.setValue(record.title, forKey: "title")
        recordMO.setValue(record.placeDescription, forKey: "placeDescription")
        recordMO.setValue(record.longitude, forKey: "longitude")
        recordMO.setValue(record.latitude, forKey: "latitude")
        recordMO.setValue(record.date, forKey: "date")
        recordMO.setValue(record.content, forKey: "content")
        travelMO.addToRecords(recordMO)

        do {
            try context.save()
            completion(.success(travelMO.toTravel()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func addLocation(
        to travel: Travel, latitude: Double?, longitude: Double?,
        completion: @escaping (Result<Location, Error>) -> Void
    ) {
        guard let travelMO = findTravel(by: travel.uuid ?? UUID())
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "LocationMO", in: context)
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        let locationMO = LocationMO(entity: entity, insertInto: context)
        locationMO.setValue(latitude, forKey: "latitude")
        locationMO.setValue(longitude, forKey: "longitude")
        travelMO.addToLocations(locationMO)

        do {
            try context.save()
            completion(.success(locationMO.toLocation()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func update(travel: Travel, completion: @escaping (Result<Travel, Error>) -> Void) {
        guard let uuid = travel.uuid as CVarArg?
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        let request = TravelMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let travels = try? context.fetch(request) as [TravelMO],
              let newTravel = travels.first
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }

        newTravel.uuid = travel.uuid
        newTravel.flag = Int64(travel.flag)
        newTravel.title = travel.title
        newTravel.startDate = travel.startDate
        newTravel.endDate = travel.endDate

        var isLandmarkResultValid = true
        newTravel.removeFromLandmarks(newTravel.landmarks ?? NSOrderedSet())
        travel.landmarks.forEach { [weak self] landmark in
            self?.addLandmark(
                to: travel, uuid: landmark.uuid, title: landmark.title,
                image: landmark.image, latitude: landmark.latitude, longitude: landmark.longitude
            ) { result in
                switch result {
                case .success:
                    break
                default:
                    isLandmarkResultValid = false
                }
            }
        }
        if !isLandmarkResultValid {
            completion(.failure(RepositoryError.landmarkError))
            return
        }

        var isRecordResultValid = true
        newTravel.removeFromRecords(newTravel.records ?? NSOrderedSet())
        travel.records.forEach { [weak self] record in
            self?.addRecord(to: travel, with: record) { result in
                switch result {
                case .success:
                    break
                default:
                    isRecordResultValid = false
                }
            }
        }
        if !isRecordResultValid {
            completion(.failure(RepositoryError.recordError))
            return
        }

        var isLocationResultValid = true
        newTravel.removeFromLocations(newTravel.locations ?? NSOrderedSet())
        travel.locations.forEach { [weak self] location in
            self?.addLocation(
                to: travel, latitude: location.latitude, longitude: location.longitude
            ) { result in
                switch result {
                case .success:
                    break
                default:
                    isLocationResultValid = false
                }
            }
        }
        if !isLocationResultValid {
            completion(.failure(RepositoryError.locationError))
            return
        }
        do {
            try context.save()
            completion(.success(newTravel.toTravel()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func updateRecord(at record: Record, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uuid = record.uuid as CVarArg?
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        let request = RecordMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let records = try? context.fetch(request) as [RecordMO],
              let newRecord = records.first
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }

        newRecord.title = record.title
        newRecord.date = record.date
        newRecord.latitude = record.latitude ?? 0
        newRecord.longitude = record.longitude ?? 0
        newRecord.placeDescription = record.placeDescription
        newRecord.photoIDs = record.photoIDs
        newRecord.content = record.content

        do {
            try context.save()
            completion(.success(()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func delete(travel: Travel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uuid = travel.uuid as CVarArg?
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        let request = TravelMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let travels = try? context.fetch(request) as [TravelMO],
              let travel = travels.first
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        context.delete(travel)

        do {
            try context.save()
            completion(.success(()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func deleteLandmark(at landmark: Landmark, completion: @escaping(Result<Void, Error>) -> Void) {
        guard let uuid = landmark.uuid as CVarArg?
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        let request = LandmarkMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let landmarks = try? context.fetch(request) as [LandmarkMO],
              let landmark = landmarks.first
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        context.delete(landmark)

        do {
            try context.save()
            completion(.success(()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
        }
    }

    func deleteRecord(at record: Record, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uuid = record.uuid as CVarArg?
        else {
            completion(.failure(RepositoryError.uuidError))
            return
        }

        let request = RecordMO.fetchRequest()
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        request.predicate = predicate
        guard let records = try? context.fetch(request) as [RecordMO],
              let record = records.first
        else {
            completion(.failure(RepositoryError.fetchError))
            return
        }
        context.delete(record)

        do {
            try context.save()
            completion(.success(()))
        } catch {
            context.rollback()
            completion(.failure(RepositoryError.saveError))
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
