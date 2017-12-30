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
    priceLabel.text = "₹ \(rent.rent)"
    infoButton(isHidden: true)

    switch rent.type {
    case .base:
      typeLabel.text = "Base Fare"
    case .km:
      typeLabel.text = "Distance Charges"
    case .time:
      typeLabel.text = "Time Charges"
    case .extraCharge:
      typeLabel.text = "Extra Charges"
      
      infoButton(isHidden: false)
    }
  }

  func infoButton(isHidden: Bool) {
    infoButton.isHidden = isHidden
  }

  @IBAction func didTapInfoButton(_ sender: Any) {

  }
  
}
