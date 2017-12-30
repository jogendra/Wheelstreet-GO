//
//  GoFareDetails.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 22/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

enum FareType: String {
  case baseRate = "baseRate"
  case kmRate = "kmRate"
  case minRate = "minuteRate"
  case hourlyRate = "hourlyRate"
  case extraCharges = "extraCharge"
}

class GoFareDetails {
  var baseRate: Int
  var kmRate: Int
  var minRate: Int

  init(baseRate: Int, kmRate: Int, minRate: Int) {
    self.baseRate = baseRate
    self.kmRate = kmRate
    self.minRate = minRate
  }

  convenience init(data: JSON) {
    guard let baseRate = data[FareType.baseRate.rawValue].int,
      let kmRate = data[FareType.kmRate.rawValue].int,
      let minRate = data[FareType.minRate.rawValue].int else {
        fatalError("No Fare Details Data Found")
    }

    self.init(baseRate: baseRate, kmRate: kmRate, minRate: minRate)
  }
}
