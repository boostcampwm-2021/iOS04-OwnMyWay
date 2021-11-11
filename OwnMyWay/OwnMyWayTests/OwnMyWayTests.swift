//
//  OwnMyWayTests.swift
//  OwnMyWayTests
//
//  Created by 김우재 on 2021/11/10.
//

import XCTest

class OwnMyWayTests: XCTestCase {

    var travel: Travel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        travel = Travel.dummy(section: .plusButton)
        travel.records = [
            Record(uuid: nil, content: "e", date: Date.init(timeInterval: 10000000, since: Date.now), latitude: nil, longitude: nil, photoURL: nil),
            Record(uuid: nil, content: "q", date: Date.init(timeInterval: 1000000, since: Date.now), latitude: nil, longitude: nil, photoURL: nil),
            Record(uuid: nil, content: "0", date: Date.init(timeInterval: 100000, since: Date.now), latitude: nil, longitude: nil, photoURL: nil),
            Record(uuid: nil, content: "a", date: Date.init(timeInterval: -1, since: Date.now), latitude: nil, longitude: nil, photoURL: nil),
            Record(uuid: nil, content: "b", date: Date.init(timeInterval: 1, since: Date.now), latitude: nil, longitude: nil, photoURL: nil),
            Record(uuid: nil, content: "c", date: Date.init(timeInterval: -100000, since: Date.now), latitude: nil, longitude: nil, photoURL: nil)
        ]
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func test_classifyRecords() {
        travel.classifyRecords()
        XCTAssertEqual(1, 1)
    }
}
