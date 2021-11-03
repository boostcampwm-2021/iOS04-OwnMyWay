//
//  CreateTravelViewController.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/02.
//

import UIKit

class CreateTravelViewController: UIViewController, Instantiable {

    private var viewModel: CreateTravelViewModelType?
    var coordinator: CreateTravelCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        let usecase = DefaultCreateTravelUsecase(travelRepository: CoreDataTravelRepository())
        self.viewModel = CreateTravelViewModel(createTravelUsecase: usecase)
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(text: sender.text)
    }

}
