//
//  CreateTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import FSCalendar
import UIKit

class CreateTravelViewController: UIViewController {
    static func instantiate() -> CreateTravelViewController {
        let storyboard = UIStoryboard(name: "CreateTravel", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CreateTravelVC")
        guard let viewController = viewController as? Self
        else { return CreateTravelViewController() }
        return viewController
    }

    @IBOutlet weak var travelTitleField: UITextField!
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var nextButton: UIButton!
    
    private var viewModel: CreateTravelViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        let usecase = DefaultCreateTravelUsecase(travelRepository: CoreDataTravelRepository())
        self.viewModel = CreateTravelViewModel(createTravelUsecase: usecase)
    }

    @IBAction func edtingTitleDidEnd(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(text: sender.text)
    }
}
