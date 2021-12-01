//
//  StartedTravelCoordinatingDelegate.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/30.
//

import Foundation

protocol StartedTravelCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord(record: Record?)
    func pushToEditTravel(travel: Travel)
    func moveToOutdated(travel: Travel)
    func pushToDetailRecord(record: Record, travel: Travel)
}
