//
//  SearchLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Combine
import Foundation

protocol SearchLandmarkViewModelType {
    var landmarks: [Landmark] { get }
    var landmarksPublisher: Published<[Landmark]>.Publisher { get }
    var searchText: String? { get }

    func configure()
    func didEnterSearchText(text: String?)
}

class SearchLandmarkViewModel: SearchLandmarkViewModelType, ObservableObject {
    @Published var landmarks: [Landmark]
    var landmarksPublisher: Published<[Landmark]>.Publisher { $landmarks }
    var searchText: String?

    private let searchLandmarkUsecase: SearchLandmarkUsecase

    init(searchLandmarkUsecase: SearchLandmarkUsecase) {
        self.landmarks = []
        self.searchLandmarkUsecase = searchLandmarkUsecase
    }

    func configure() {
        searchLandmarkUsecase.executeFetch { [weak self] landmarks in
            self?.landmarks = landmarks
        }
    }

    func didEnterSearchText(text: String?) {
        guard let text = text else {
            configure() // 검색어가 없을 경우 모든 결과 조회
            return
        }
        searchLandmarkUsecase.executeSearch(searchText: text) { [weak self] searchResult in
            self?.landmarks = searchResult
        }
    }
}
