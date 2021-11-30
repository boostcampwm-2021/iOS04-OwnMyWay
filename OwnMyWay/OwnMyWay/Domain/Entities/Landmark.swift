//
//  Landmark.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//

import Foundation

struct Landmark {
    var uuid: UUID?
    var image: URL?
    var latitude: Double?
    var longitude: Double?
    var title: String?
}

extension Landmark: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
