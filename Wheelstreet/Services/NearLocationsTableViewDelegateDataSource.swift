//
//  NearLocationsTableViewDelegateDataSource.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

fileprivate enum Defaults {
  static let rowHeight: CGFloat = 80.0
}

protocol NearLocationsTableViewDelegate: class {
  func didSelectTableViewCell(atIndexPath indexPath: IndexPath, location: GOSafeLocation)
}

extension UIViewController: NearLocationsTableViewDelegate {
  func didSelectTableViewCell(atIndexPath indexPath: IndexPath, location: GOSafeLocation) {
    WheelstreetCommon.googleMapsDirections(toLocation: location, cancelationHandler: {
      WheelstreetViews.somethingWentWrongAlertView()
    })
  }
}

class NearLocationsTableViewDelegateDataSource: NSObject {

  private var locations: [GOSafeLocation] = []
  weak var delegate: NearLocationsTableViewDelegate?

  init(locations: [GOSafeLocation]) {
    self.locations = locations
  }

  func setUpForTableView(_ tableView: UITableView) {
    tableView.register(NearestLocationTableViewCell.self)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    tableView.isScrollEnabled = false
    tableView.backgroundColor = UIColor.clear
    tableView.showsVerticalScrollIndicator = false
  }

  
}

extension NearLocationsTableViewDelegateDataSource: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return Defaults.rowHeight
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.didSelectTableViewCell(atIndexPath: indexPath, location: locations[indexPath.row])
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "PARKING LOCATIONS"
  }
}

extension NearLocationsTableViewDelegateDataSource: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: NearestLocationTableViewCell = tableView.dequeReusableCell(forIndexPath: indexPath)
    cell.configure(withParkingLocation: locations[indexPath.row])
    return cell
  }
}


