//
//  AddRecordViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import UIKit

class AddRecordViewController: UIViewController, Instantiable {
    @IBOutlet weak var photoCollectionView: UICollectionView!

    private var viewModel: AddRecordViewModel?
    private var dataSource: [URL] = []
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureNibs()
        self.configurePhotoCollectionView()
        self.configureNavigation()
        self.configureCancellable()
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }

    private func configureNibs() {
        self.photoCollectionView.register(
            UINib(nibName: PhotoCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PhotoCell.identifier
        )
    }

    private func configurePhotoCollectionView() {
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }

    private func configureNavigation() {
        self.navigationItem.title = "게시물 작성"

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backButtonAction)
        )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(submitButtonAction)
        )
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid ?? false
            }
            .store(in: &cancellables)

        self.viewModel?.photoPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] photos in
                print(photos)
                self?.dataSource = photos
                self?.photoCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }

    @objc private func backButtonAction() {
        self.viewModel?.didTouchBackButton()
    }

    @objc private func submitButtonAction() {
        self.viewModel?.didTouchSubmitButton()
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(with: sender.text)
    }

}

extension AddRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return self.dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier, for: indexPath
        ) as? PhotoCell
        else { return UICollectionViewCell() }
        cell.configure(url: self.dataSource[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }

}
