//
//  AddRecordViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest

class AddRecordViewModelTest: XCTestCase {

    enum TestError: Error {
    case error
    }

    var creatingViewModel: AddRecordViewModel!
    var editingViewModel: AddRecordViewModel!
    private let testDate = Date(timeIntervalSince1970: 0)

    class MockCoordinator: AddRecordCoordinatingDelegate {
        func popToParent(with record: Record) {}
        
        func presentToSearchLocation() {}
    }

    class MockUsecase: AddRecordUsecase {
        private let isValidateUsecase: Bool

        init(isValidate: Bool) {
            isValidateUsecase = isValidate
        }

        func executeValidationTitle(with title: String?) -> Bool {
            return self.isValidateUsecase
        }
        
        func executeValidationDate(with date: Date?) -> Bool {
            return self.isValidateUsecase
        }
        
        func executeValidationCoordinate(with coordinate: Location) -> Bool {
            return self.isValidateUsecase
        }
        
        func executePickingPhoto(with url: URL, completion: (Result<String, Error>) -> Void) {
            if self.isValidateUsecase {
                completion(.success("성공"))
            } else {
                let error = TestError.error
                completion(.failure(error))
            }
        }
        
        func executeRemovingPhoto(of photoID: String, completion: (Result<Void, Error>) -> Void) {
            if self.isValidateUsecase {
                completion(.success(Void()))
            } else {
                let error = TestError.error
                completion(.failure(error))
            }
        }
    }

    override func setUp() {
        super.setUp()
        self.creatingViewModel = DefaultAddRecordViewModel(
            record: nil, usecase: MockUsecase(isValidate: true),
            coordinatingDelegate: MockCoordinator(), isEditingMode: false
        )
        
        let record = Record(uuid: UUID(), title: "테스트제목", content: "테스트내용", date: testDate, latitude: 0, longitude: 0, photoIDs: ["test1.jpeg", "test2.jpeg"], placeDescription: "테스트장소설명")
        self.editingViewModel = DefaultAddRecordViewModel(
            record: record, usecase: MockUsecase(isValidate: true),
            coordinatingDelegate: MockCoordinator(), isEditingMode: true
        )
    }

    override func tearDown() {
        self.creatingViewModel = nil
        self.editingViewModel = nil
        super.tearDown()
    }

    func test_장소입력() {
        let testRecordPlace = "테스트제목"
        let testLatitude: Double = 1
        let testLongtitude: Double = 1
        self.creatingViewModel.locationDidUpdate(
            recordPlace: testRecordPlace, latitude: testLatitude, longitude: testLongtitude
        )
        XCTAssertEqual(self.creatingViewModel.record.placeDescription, testRecordPlace)
        XCTAssertEqual(self.creatingViewModel.record.latitude, testLatitude)
        XCTAssertEqual(self.creatingViewModel.record.longitude, testLongtitude)
    }

    func test_제목입력() {
        let testTitle = "테스트타이틀"
        self.creatingViewModel.didEnterTitle(with: testTitle)
        XCTAssertEqual(self.creatingViewModel.record.title, testTitle)
    }

    func test_시간입력() {
        let interval: Double = 100
        let testDate = Date(timeIntervalSince1970: interval)
        self.creatingViewModel.didEnterTime(with: testDate)
        XCTAssertEqual(self.creatingViewModel.record.date, testDate)
    }

    func test_좌표입력() {
        let testLatitude: Double = 1
        let testLongtitude: Double = 1
        self.creatingViewModel.didEnterCoordinate(latitude: testLatitude, longitude: testLongtitude)
        XCTAssertEqual(self.creatingViewModel.record.latitude, testLatitude)
        XCTAssertEqual(self.creatingViewModel.record.longitude, testLongtitude)
    }

    func test_내용입력() {
        let testContent = "테스트내용"
        self.creatingViewModel.didEnterContent(with: testContent)
        XCTAssertEqual(self.creatingViewModel.record.content, testContent)
    }

    func test_사진_URL_입력() {
        
    }

    func test_사진제거() {
        let removeIndex = 0
        let expectedResult = ["test2.jpeg"]
        self.editingViewModel.didRemovePhoto(at: removeIndex)
        XCTAssertEqual(self.editingViewModel.record.photoIDs, expectedResult)
    }

    func test_제출버튼_터치() {
        
    }

    func test_장소버튼_터치() {
        
    }

    func test_뒤로버튼_터치() {
        
    }

    func test_좌표변경() {
        let newLat = 32.0, newLng = 127.0
        let newPlace = "독도"
        self.editingViewModel.locationDidUpdate(recordPlace: newPlace, latitude: newLat, longitude: newLng)
        XCTAssertEqual(self.editingViewModel.record.placeDescription, newPlace)
        XCTAssertEqual(self.editingViewModel.record.latitude, newLat)
        XCTAssertEqual(self.editingViewModel.record.longitude, newLng)
    }

    func test_장소이름() {
        
    }

}
