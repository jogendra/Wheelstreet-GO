//
//  GoReading.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 26/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

class GoReading {
  var maximum: Int
  var current: Int
  var minimum: Int

  init(minimum: Int, current: Int, maximum: Int) {
    self.minimum = minimum
    self.current = current
    self.maximum = maximum
  }

  convenience init(data: JSON) {
    guard let minimum = data["minimum"].int,
      let current = data["current"].int,
      let maximum = data["maximum"].int else {
        fatalError("Unable to intiialise GoReading")
    }

    self.init(minimum: minimum, current: current, maximum: maximum)
  }
}
