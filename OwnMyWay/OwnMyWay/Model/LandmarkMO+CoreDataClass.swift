//
//  LandmarkMO+CoreDataClass.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/04.
//
//

import CoreData
import Foundation

@objc(LandmarkMO)
public class LandmarkMO: NSManagedObject {

    // MO 객체에서 Landmark 생성
    func toLandmark() -> Landmark {
        return Landmark(
            uuid: self.uuid,
            image: self.image,
            latitude: self.latitude,
            longitude: self.longitude,
            title: self.title
        )
    }
    
    // 입력받은 Landmark 객체로 MO 생성
    func fromLandmark(landmark: Landmark) {
        self.uuid = landmark.uuid
        self.image = landmark.image
        self.latitude = landmark.latitude ?? 0
        self.longitude = landmark.longitude ?? 0
        self.title = landmark.title
    }
    
}
