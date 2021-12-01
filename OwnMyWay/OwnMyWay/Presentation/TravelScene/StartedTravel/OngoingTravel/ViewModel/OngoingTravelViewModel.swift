//
//  OngoingViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation

protocol OngoingTravelViewModel {
    var travel: Travel { get }
    var travelPublisher: Published<Travel>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }

    func viewWillAppear()
    func didUpdateTravel(to travel: Travel)
    func didTouchAddRecordButton()
    func didTouchRecordCell(at record: Record)
    func didTouchBackButton()
    func didTouchEditButton()
    func didTouchFinishButton()
    func didUpdateCoordinate(latitude: Double, longitude: Double)
    func didUpdateRecord(record: Record)
}
