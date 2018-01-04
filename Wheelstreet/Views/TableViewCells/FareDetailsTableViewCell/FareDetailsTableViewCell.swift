//
//  FareDetailsTableViewCell.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 22/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class FareDetailsTableViewCell: UITableViewCell, NibLoadableView, WheelstreetReusableView {

  @IBOutlet var typeLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!

  @IBOutlet var infoButton: UIButton!

  var extraCharge: Int?

  override func awakeFromNib() {
        super.awakeFromNib()
  }

  func configure(rent: GORent) {
    infoButton(isHidden: true)

    switch rent.type {
    case .base:
      typeLabel.text = "Base Fare"
      priceLabel.text = "₹ \(rent.rent)"
    case .km:
      typeLabel.text = "Distance Charges"
      priceLabel.text = "₹ \(rent.rent)"
    case .time:
      typeLabel.text = "Time Charges"
      priceLabel.text = "₹ \(rent.rent)"
    case .extraCharge:
      typeLabel.text = "Extra Charges"
      priceLabel.text = "₹ \(rent.rent)"
      infoButton(isHidden: false)
    case .bookedOn:
      typeLabel.text = "Booked On"
      priceLabel.text = "\(rent.rent)"

    }
  }

  func infoButton(isHidden: Bool) {
    infoButton.isHidden = isHidden
  }

  @IBAction func didTapInfoButton(_ sender: Any) {

  }
  
}
