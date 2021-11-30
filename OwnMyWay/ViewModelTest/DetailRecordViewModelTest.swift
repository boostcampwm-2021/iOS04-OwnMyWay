//
//  DetailRecordViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest

class DetailRecordViewModelTest: XCTestCase {

    class MockUsecase: DetailRecordUsecase {
        func executeRecordUpdate(record: Record, completion: @escaping (Result<Void, Error>) -> Void) {
            if record.uuid == nil {
                completion(.failure(EnterTitleError.nilTitle))
            } else {
                completion(.success(()))
            }
        }
        
        func executeRecordDeletion(at record: Record, completion: @escaping (Result<Void, Error>) -> Void) {
            if record.title == "테스트 레코드" {
                completion(.success(()))
            } else {
                completion(.failure(EnterTitleError.nilTitle))
            }
        }
    }
    
    class MockCoordinator: DetailRecordCoordinatingDelegate {
        var record: Record?
        var travel: Travel?
        var isPopable: Bool?
        var images: [String] = []
        var index: Int?
        
        func pushToAddRecord(record: Record) {
            self.record = record
        }
        
        func popToParent(with travel: Travel, isPopable: Bool) {
            self.travel = travel
            self.isPopable = isPopable
        }
        
        func presentDetailImage(images: [String], index: Int) {
            self.images = images
            self.index = index
        }
    }
    
    var viewModel: DetailRecordViewModel!
    var coordinator: MockCoordinator!
    
    override func setUp() {
        let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        let record = Record(uuid: uuid, title: "테스트 레코드", content: "테스트 레코드 내용", date: Date(), latitude: 10, longitude: 10, photoIDs: ["1.jpg", "2.jpg", "3.jpg"], placeDescription: "테스트 레코드 장소")
        
        self.coordinator = MockCoordinator()
        self.viewModel = DefaultDetailRecordViewModel.init(
            record: record,
            travel: Travel(uuid: UUID(), flag: 1, title: "테스트 여행", startDate: Date(), endDate: Date(), landmarks: [], records: [record], locations: []),
            usecase: MockUsecase(),
            coordinatingDelegate: self.coordinator
        )
    }

    override func tearDown() {
        self.coordinator = nil
        self.viewModel = nil
    }

    func test_뒤로가기_버튼() {
        self.viewModel.didTouchBackButton()
        XCTAssertTrue(self.coordinator.isPopable == false)
        XCTAssertTrue(self.coordinator.travel?.title == "테스트 여행")
        XCTAssertTrue(self.coordinator.travel?.flag == 1)
        XCTAssertTrue(self.coordinator.travel?.landmarks.count == 0)
        XCTAssertTrue(self.coordinator.travel?.records.count == 1)
        XCTAssertTrue(self.coordinator.travel?.locations.count == 0)
    }
    
    func test_수정_버튼() {
        self.viewModel.didTouchEditButton()
        XCTAssertTrue(self.coordinator.record?.title == "테스트 레코드")
        XCTAssertTrue(self.coordinator.record?.content == "테스트 레코드 내용")
        XCTAssertTrue(self.coordinator.record?.placeDescription == "테스트 레코드 장소")
        XCTAssertTrue(self.coordinator.record?.longitude == 10.0)
        XCTAssertTrue(self.coordinator.record?.photoIDs?.count == 3)
    }
    
    func test_업데이트_버튼_실패() {

        let expectation = XCTestExpectation()

        var cancellable = self.viewModel.errorPublisher.sink { error in
            if error == nil { return }
            XCTAssertNotNil(error as? EnterTitleError)
            expectation.fulfill()
        }

        self.viewModel.didUpdateRecord(record: Record(uuid: nil, title: "업데이트 테스트", content: "업데이트 테스트 내용", date: Date(), latitude: 100, longitude: 100, photoIDs: [], placeDescription: "업데이트 테스트 장소"))
        wait(for: [expectation], timeout: 2.0)
    }

    func test_업데이트_버튼_성공_레코드_없음() {
        
        let expectation = XCTestExpectation()

        var cancellable = self.viewModel.errorPublisher.sink { error in
            if error == nil { return }
            XCTAssertNotNil(error as? RepositoryError)
            expectation.fulfill()
        }

        self.viewModel.didUpdateRecord(record: Record(uuid: UUID(), title: "업데이트 테스트", content: "업데이트 테스트 내용", date: Date(), latitude: 100, longitude: 100, photoIDs: [], placeDescription: "업데이트 테스트 장소"))
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_업데이트_버튼_성공_레코드_있음() {
        let expectation = XCTestExpectation()
        
        var cancellable = self.viewModel.recordPublisher.sink { record in
            if record.title != "업데이트 테스트" { return }
            XCTAssertTrue(record.title == "업데이트 테스트")
            XCTAssertTrue(record.content == "업데이트 테스트 내용")
            XCTAssertTrue(record.placeDescription == "업데이트 테스트 장소")
            XCTAssertTrue(record.latitude == 100)
            expectation.fulfill()
        }
        
        let uuid = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        self.viewModel.didUpdateRecord(record: Record(uuid: uuid, title: "업데이트 테스트", content: "업데이트 테스트 내용", date: Date(), latitude: 100, longitude: 100, photoIDs: [], placeDescription: "업데이트 테스트 장소"))
        wait(for: [expectation], timeout: 2)
        
    }
    
    func test_삭제_버튼() {
        self.viewModel.didTouchDeleteButton()
        XCTAssertTrue(self.coordinator.travel?.records.count == 0)
        XCTAssertTrue(self.coordinator.isPopable == true)
    }
    
    func test_이미지_터치() {
        self.viewModel.didTouchImageView(index: 2)
        XCTAssertTrue(self.coordinator.index == 2)
        XCTAssertTrue(self.coordinator.images.count == 3)
    }
}
