//
//  GORent.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 26/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

enum RentType: String {
  case base = "base"
  case km = "km"
  case time = "time"
  case extraCharge = "extraCharge"
  case bookedOn = "bookedOn"
}

class GORent {
  var type : RentType
  var rent : String
  var rate : Double
  var total : Int

  init(type: RentType, rent: String, rate: Double, total: Int) {
    self.type = type
    self.rent = rent
    self.rate = rate
    self.total = total
  }

  convenience init(typeString: String, data: JSON) {
    guard let type = RentType(rawValue: typeString) else {
      fatalError("Unable to initialise GORent")
    }

    switch type {
    case .km:
      self.init(type: type, rent: "\(data["rate"].doubleValue)", rate: data["kmRate"].doubleValue, total: data["totalKilometer"].intValue)
    case .time:
     self.init(type: type, rent: "\(data["rate"].doubleValue)", rate: data["hourlyRate"].doubleValue, total: data["totalDuration"].intValue)
    case .base:
    self.init(type: type, rent: "\(data.doubleValue)", rate: 0, total: 0)
    case .extraCharge:
      self.init(type: type, rent: "\(data.doubleValue)", rate: 0, total: 0)
    case .bookedOn:
      self.init(type: type, rent: "\(data.doubleValue)", rate: 0, total: 0)
    }

  }
}
