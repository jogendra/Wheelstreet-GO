//
//  NearestLocationTableViewCell.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class NearestLocationTableViewCell: UITableViewCell, NibLoadableView, WheelstreetReusableView {

  @IBOutlet var borderView: UIView!
  @IBOutlet var titleLabel: UILabel!
  
  @IBOutlet var distanceLabel: UILabel!

  @IBOutlet var locationIcon: UIImageView!
  @IBOutlet var directionsButton: UIButton!

  var location: GOSafeLocation?

  override func awakeFromNib() {
        super.awakeFromNib()

        borderView.layer.cornerRadius = 4.0
        borderView.layer.masksToBounds = true
        borderView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        borderView.layer.borderWidth = 2.0

  }

  func configure(withParkingLocation location: GOSafeLocation) {
    self.location = location
    selectionStyle = .none
    separatorInset = UIEdgeInsetsMake(0, UIScreen.main.bounds.width, 0, 0)
    titleLabel.text = location.title
    guard let distance = location.distance else {
      locationIcon.image = nil
      distanceLabel.text = ""
      return
    }

    locationIcon.image = #imageLiteral(resourceName: "location_gps")
    distanceLabel.text = "\(distance.rounded())".appending(" km")
  }


  @IBAction func didTapDirectionsButton(_ sender: Any) {
    if let location = location {
      WheelstreetCommon.googleMapsDirections(toLocation: location, cancelationHandler: {
        WheelstreetViews.somethingWentWrongAlertView()
      })
    }
    else {
      WheelstreetViews.somethingWentWrongAlertView()
    }
  }

}
