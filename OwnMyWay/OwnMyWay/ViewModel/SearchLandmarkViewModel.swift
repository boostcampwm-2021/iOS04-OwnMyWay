//
//  SearchLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Combine
import Foundation

protocol SearchLandmarkViewModelType {
    var landmarks: [LandmarkDTO]? { get }
    var searchText: String? { get }

    func configure()
    func didEnterSearchText(text: String?)
}

class SearchLandmarkViewModel: SearchLandmarkViewModelType {

    @Published var landmarks: [LandmarkDTO]?
    var searchText: String?

    private let searchLandmarkUsecase: SearchLandmarkUsecase

    init(searchLandmarkUsecase: SearchLandmarkUsecase) {
        self.searchLandmarkUsecase = searchLandmarkUsecase
    }

    func configure() {
        searchLandmarkUsecase.executeFetch { [weak self] landmarkDTOs in
            self?.landmarks = landmarkDTOs
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
