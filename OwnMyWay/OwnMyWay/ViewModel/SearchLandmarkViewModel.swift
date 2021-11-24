//
//  SearchLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Combine
import Foundation

protocol SearchLandmarkViewModel {
    var landmarksPublisher: Published<[Landmark]>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }

    func viewDidLoad()
    func didChangeSearchText(with text: String)
    func didTouchLandmarkCard(at index: Int)
}

protocol SearchLandmarkCoordinatingDelegate: AnyObject {
    func dismissToAddLandmark(landmark: Landmark)
}

class DefaultSearchLandmarkViewModel: SearchLandmarkViewModel, ObservableObject {

    var landmarksPublisher: Published<[Landmark]>.Publisher { $landmarks }
    var errorPublisher: Published<Error?>.Publisher { $error }

    private let usecase: SearchLandmarkUsecase
    private weak var coordinatingDelegate: SearchLandmarkCoordinatingDelegate?

    @Published private var landmarks: [Landmark]
    @Published private var searchText: String
    @Published private var error: Error?
    private var cancellables: Set<AnyCancellable>

    init(
        usecase: SearchLandmarkUsecase,
        coordinatingDelegate: SearchLandmarkCoordinatingDelegate
    ) {
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
        self.landmarks = []
        self.searchText = ""
        self.cancellables = []
        self.bind()
    }

    func viewDidLoad() {
        usecase.executeFetch { [weak self] result in
            switch result {
            case .success(let landmarks):
                self?.landmarks = landmarks
            case .failure(let error):
                self?.error = error
            }
        }
    }

    func didChangeSearchText(with text: String) {
        self.searchText = text
    }

    func didTouchLandmarkCard(at index: Int) {
        guard landmarks.startIndex..<landmarks.endIndex ~= index else {
            self.error = ModelError.indexError
            return
        }
        self.coordinatingDelegate?.dismissToAddLandmark(landmark: landmarks[index])
    }

    // MARK: Internal Private Functions
    private func search(with text: String) {
        if text.isEmpty {
            self.viewDidLoad()
        } else {
            usecase.executeSearch(by: text) { [weak self] searchResult in
                switch searchResult {
                case .success(let landmarks):
                    self?.landmarks = landmarks
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }

    private func bind() {
        self.$searchText
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.search(with: searchText)
            }.store(in: &cancellables)
    }
}
