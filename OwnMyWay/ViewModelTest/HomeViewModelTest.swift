//
//  HomeViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest
import CoreData

class HomeViewModelTest: XCTestCase {

    var vm = DefaultHomeViewModel(
        usecase: DefaultHomeUsecase(repository: CoreDataTravelRepository(contextFetcher: MockContextFetcher())),
        coordinatingDelegate: MockDelegate()
    )
    
    override func setUp() {
        
    }
    
    override func tearDown() {
        
    }

}

class MockContextFetcher: ContextAccessable {
    func fetchContext() -> NSManagedObjectContext {
        return NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
    }
}

class MockDelegate: HomeCoordinatingDelegate {
    func pushToCreateTravel() { }
    func pushToReservedTravel(travel: Travel) { }
    func pushToOngoingTravel(travel: Travel) { }
    func pushToOutdatedTravel(travel: Travel) { }
}
