//
//  UsecaseTest.swift
//  UsecaseTest
//
//  Created by 강현준 on 2021/11/30.
//

import XCTest
@testable import OwnMyWay
import CoreData

class AddRecordUsecaseTest: XCTestCase {
    class MokContextFetcher: ContextAccessable {
        func fetchContext() -> NSManagedObjectContext {
            return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        }
    }
    
    var usecase: DefaultAddRecordUsecase!
    
    override func setUpWithError() throws {
        self.usecase = DefaultAddRecordUsecase(
            repository: CoreDataTravelRepository(contextFetcher: MokContextFetcher()),
            imageFileManager: ImageFileManager.shared
        )
    }

    override func tearDownWithError() throws {
        self.usecase = nil
    }
    
    func test_타이틀_검증() {
        var testTitle1 = "Test입니다."
        var testTitle2 = ""
        var testTitle3 = "Test입니다.Test입니다.Test입니다.Test입니다."
        XCTAssertTrue(self.usecase.executeValidationTitle(with: testTitle1))
        XCTAssertFalse(self.usecase.executeValidationTitle(with: testTitle2))
        XCTAssertFalse(self.usecase.executeValidationTitle(with: testTitle3))
    }
    
    func test_날짜_검증() {
        var date = Date()
        var nilDate: Date? = nil
        XCTAssertTrue(self.usecase.executeValidationDate(with: date))
        XCTAssertFalse(self.usecase.executeValidationDate(with: nilDate))
    }
    
    func test_위치_검증() {
        var location1 = Location(latitude: -90, longitude: -180)
        var location2 = Location(latitude: 90, longitude: 180)
        var location3 = Location(latitude: -91, longitude: -180)
        var location4 = Location(latitude: 90, longitude: 181)
        XCTAssertTrue(self.usecase.executeValidationCoordinate(with: location1))
        XCTAssertTrue(self.usecase.executeValidationCoordinate(with: location2))
        XCTAssertFalse(self.usecase.executeValidationCoordinate(with: location3))
        XCTAssertFalse(self.usecase.executeValidationCoordinate(with: location4))
    }
}
