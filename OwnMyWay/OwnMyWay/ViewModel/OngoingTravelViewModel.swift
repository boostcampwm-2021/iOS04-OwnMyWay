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

    func didUpdateTravel(to travel: Travel)
    func didTouchAddRecordButton()
    func didTouchRecordCell(at record: Record)
    func didTouchBackButton()
    func didTouchEditTravelButton()
    func didTouchFinishButton()
    func didUpdateCoordinate(latitude: Double, longitude: Double)
}

protocol OngoingCoordinatingDelegate: AnyObject {
    func popToHome()
    func pushToAddRecord(travel: Travel)
    func pushToEditTravel()
    func moveToOutdated(travel: Travel)
    func pushToDetailRecord(record: Record)
}

class DefaultOngoingTravelViewModel: OngoingTravelViewModel {
    var travelPublisher: Published<Travel>.Publisher { $travel }

    @Published private(set) var travel: Travel

    private let usecase: OngoingTravelUsecase
    private weak var coordinatingDelegate: OngoingCoordinatingDelegate?

    init(
        travel: Travel,
        usecase: OngoingTravelUsecase,
        coordinatingDelegate: OngoingCoordinatingDelegate
    ) {
        // FIXME: 임시 테스트 추가
        var tmpTravel = travel
        tmpTravel.records = [Record(uuid: UUID(), content: "SungSanBong", date: Date(timeIntervalSinceNow: -86400), latitude: 33.458126, longitude: 126.94258, photoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Seongsan_Ilchulbong_from_the_air.jpg/544px-Seongsan_Ilchulbong_from_the_air.jpg")),
         Record(uuid: UUID(), content: "VENI VIDI VICI!", date: Date(timeIntervalSinceNow: 86400), latitude: 33.361425, longitude: 126.529418, photoURL: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Hallasan_2.jpg/600px-Hallasan_2.jpg")),
         Record(uuid: UUID(), content: "HelloKitty is motchamchi", date: Date(), latitude: 33.2903582726355, longitude: 126.35198172436094, photoURL: URL(string: "https://search.pstatic.net/common/?autoRotate=true&quality=95&type=w750&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20190717_293%2F1563353611332Pkz6e_JPEG%2Fhellokitty_banner_2.jpg")),
         Record(uuid: UUID(), content: "I Love Teddy Bear!", date: Date(timeIntervalSinceNow: 86400), latitude: 33.25052535513408, longitude: 126.4121400108651, photoURL: URL(string: "https://search.pstatic.net/common/?autoRotate=true&quality=95&type=w750&src=https%3A%2F%2Fldb-phinf.pstatic.net%2F20210806_79%2F1628217288477ciuOK_JPEG%2FIMG_1321.jpg"))]
        self.travel = tmpTravel
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didUpdateTravel(to travel: Travel) {}

    func didTouchAddRecordButton() {
        self.coordinatingDelegate?.pushToAddRecord(travel: self.travel)
    }

    func didTouchRecordCell(at record: Record) {
        self.coordinatingDelegate?.pushToDetailRecord(record: record)
    }

    func didTouchBackButton() {}
    func didTouchEditTravelButton() {}

    func didTouchFinishButton() {
        self.travel.flag = Travel.Section.outdated.index
        self.usecase.executeFlagUpdate(of: self.travel)
        self.coordinatingDelegate?.moveToOutdated(travel: self.travel)
    }

    func didUpdateCoordinate(latitude: Double, longitude: Double) {
        self.travel.locations.append(Location(latitude: latitude, longitude: longitude))
        self.usecase.executeLocationUpdate(
            of: self.travel, latitude: latitude, longitude: longitude
        )
    }

}
