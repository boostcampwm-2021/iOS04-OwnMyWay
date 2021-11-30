//
//  SearchLandmarkViewModelTest.swift
//  ViewModelTest
//
//  Created by 김우재 on 2021/11/30.
//

import XCTest
import Combine

class SearchLandmarkViewModelTest: XCTestCase {
    
    class MockUsecase: SearchLandmarkUsecase {
        func executeFetch(completion: @escaping (Result<[Landmark], Error>) -> Void) {
            let result = [
                Landmark(uuid: UUID(), image: nil, latitude: 10.0, longitude: 20.0, title: "테스트1"),
                Landmark(uuid: UUID(), image: nil, latitude: 20.0, longitude: 10.0, title: "테스트2")
            ]
            completion(.success(result))
        }
        
        func executeSearch(by text: String, completion: @escaping (Result<[Landmark], Error>) -> Void) {
            if text == "헬로키티" {
                completion(.success([Landmark(uuid: UUID(), image: nil, latitude: 1.0, longitude: 2.0, title: "헬로키티 성공")]))
            } else {
                completion(.failure(JSONError.fileError))
            }
        }
    }
    
    class MockCoordinator: SearchLandmarkCoordinatingDelegate {
        var landmark: Landmark?
        
        func dismissToAddLandmark(landmark: Landmark) {
            self.landmark = landmark
        }
    }

    var viewModel: SearchLandmarkViewModel!
    var coordinator: MockCoordinator!
    
    override func setUp() {
        self.coordinator = MockCoordinator()
        self.viewModel = DefaultSearchLandmarkViewModel(
            usecase: MockUsecase(),
            coordinatingDelegate: self.coordinator
        )
    }

    override func tearDown() {
        self.coordinator = nil
        self.viewModel = nil
    }
    
    func test_관광명소_초기설정() {
        let expectation = XCTestExpectation()
        
        var cancellable = self.viewModel.landmarksPublisher.sink { landmarks in
            if landmarks.count == 0 { return }
            XCTAssertTrue(landmarks.count == 2)
            XCTAssertTrue(landmarks[0].title == "테스트1")
            XCTAssertTrue(landmarks[0].latitude == 10.0)
            XCTAssertTrue(landmarks[1].title == "테스트2")
            XCTAssertTrue(landmarks[1].longitude == 10.0)
            expectation.fulfill()
        }
        
        self.viewModel.viewDidLoad()
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_찾는_단어_변경_성공() {
        let expectation = XCTestExpectation()
        
        var cancellable = self.viewModel.landmarksPublisher.sink { landmarks in
            if landmarks.count == 0 { return }
            XCTAssertTrue(landmarks.count == 1)
            XCTAssertTrue(landmarks[0].title == "헬로키티 성공")
            XCTAssertTrue(landmarks[0].longitude == 2.0)
            XCTAssertTrue(landmarks[0].latitude == 1.0)
            expectation.fulfill()
        }

        self.viewModel.didChangeSearchText(with: "헬로키티")
        wait(for: [expectation], timeout: 2.0)
    }

    func test_찾는_단어_변경_실패() {
        let expectation = XCTestExpectation()
        
        var cancellable = self.viewModel.errorPublisher.sink { error in
            if error == nil { return }
            XCTAssertNotNil(error as? JSONError)
            expectation.fulfill()
        }

        self.viewModel.didChangeSearchText(with: "그 외")
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_관광명소_추가_성공() {
        self.viewModel.viewDidLoad()
        self.viewModel.didTouchLandmarkCard(at: 1)
        XCTAssertTrue(self.coordinator.landmark?.title == "테스트2")
        XCTAssertTrue(self.coordinator.landmark?.latitude == 20.0)
    }
    
    func test_관광명소_추가_실패() {
        let expectation = XCTestExpectation()
        
        var cancellable = self.viewModel.errorPublisher.sink { error in
            if error == nil { return }
            XCTAssertNotNil(error as? ModelError)
            expectation.fulfill()
        }

        self.viewModel.viewDidLoad()
        self.viewModel.didTouchLandmarkCard(at: 2)
        wait(for: [expectation], timeout: 2.0)
    }
}
