//
//  SearchLocationViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/18.
//

import UIKit
import MapKit

final class SearchLocationViewController: UIViewController, Instantiable {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var tableView: UITableView!

    private var viewModel: SearchLocationViewModel?
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureSearchBar()
        self.configureSearchCompleter()
        self.configureTableView()
    }

    func bind(viewModel: SearchLocationViewModel) {
        self.viewModel = viewModel
    }

    private func configureSearchBar() {
        self.searchBar.delegate = self
    }

    private func configureSearchCompleter() {
        self.searchCompleter.delegate = self
        self.searchCompleter.resultTypes = .pointOfInterest
        self.searchCompleter.region = self.mapView.region
    }

    private func configureTableView() {
        self.tableView.register(
            UINib(nibName: LocationTableViewCell.identifier, bundle: nil),
            forCellReuseIdentifier: LocationTableViewCell.identifier
        )
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
}

extension SearchLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.searchResults.removeAll()
            self.tableView.reloadData()
        }
        self.searchCompleter.queryFragment = searchText
    }
}

extension SearchLocationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let select = self.searchResults[indexPath.row]
        let request = MKLocalSearch.Request(completion: select)
        request.resultTypes = .pointOfInterest
        request.region = self.mapView.region
        let search = MKLocalSearch(request: request)

        search.start { (response, error) in
            guard error == nil
            else { return }
            guard let placeMark = response?.mapItems.first?.placemark
            else { return }

            self.viewModel?.didSelectLocation(
                title: placeMark.name,
                latitude: placeMark.coordinate.latitude.magnitude,
                longitude: placeMark.coordinate.longitude.magnitude
            )
        }
    }
}

extension SearchLocationViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard (0..<searchResults.count) ~= indexPath.row,
              let cell = tableView.dequeueReusableCell(
                withIdentifier: LocationTableViewCell.identifier,
                for: indexPath
              ) as? LocationTableViewCell
        else { return UITableViewCell() }
        cell.configure(
            title: searchResults[indexPath.row].title,
            subTitle: searchResults[indexPath.row].subtitle
        )
        return cell
    }
}

extension SearchLocationViewController {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension SearchLocationViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchResults = completer.results
        self.tableView.reloadData()
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        return
    }
}
