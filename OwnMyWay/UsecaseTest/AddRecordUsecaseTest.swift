//
//  UsecaseTest.swift
//  UsecaseTest
//
//  Created by 강현준 on 2021/11/30.
//

import XCTest
import CoreData

class AddRecordUsecaseTest: XCTestCase {
    class MokContextFetcher: ContextAccessable {
        func fetchContext() -> NSManagedObjectContext {
            return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
    }
    
    var usecase: AddRecordUsecase!
    
    override func setUp() {
        super.setUp()
        self.usecase = DefaultAddRecordUsecase(
            repository: CoreDataTravelRepository(contextFetcher: MokContextFetcher()),
            imageFileManager: ImageFileManager.shared
        )
    }

    override func tearDown() {
        self.usecase = nil
        super.tearDown()
    }
    
    func test_타이틀_검증() {
        let testTitle1 = "Test입니다."
        let testTitle2 = ""
        let testTitle3 = "Test입니다.Test입니다.Test입니다.Test입니다."
        XCTAssertTrue(self.usecase.executeValidationTitle(with: testTitle1))
        XCTAssertFalse(self.usecase.executeValidationTitle(with: testTitle2))
        XCTAssertFalse(self.usecase.executeValidationTitle(with: testTitle3))
    }
    
    func test_날짜_검증() {
        let date = Date()
        let nilDate: Date? = nil
        XCTAssertTrue(self.usecase.executeValidationDate(with: date))
        XCTAssertFalse(self.usecase.executeValidationDate(with: nilDate))
    }
    
    func test_위치_검증() {
        let location1 = Location(latitude: -90, longitude: -180)
        let location2 = Location(latitude: 90, longitude: 180)
        let location3 = Location(latitude: -91, longitude: -180)
        let location4 = Location(latitude: 90, longitude: 181)
        XCTAssertTrue(self.usecase.executeValidationCoordinate(with: location1))
        XCTAssertTrue(self.usecase.executeValidationCoordinate(with: location2))
        XCTAssertFalse(self.usecase.executeValidationCoordinate(with: location3))
        XCTAssertFalse(self.usecase.executeValidationCoordinate(with: location4))
    }
}
