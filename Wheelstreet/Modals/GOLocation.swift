//
//  GOLocation.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class GOLocation {
  var latitude: Double
  var longitude: Double

  init(latitude: Double, longitude: Double) {
    self.latitude = latitude
    self.longitude = longitude
  }

  convenience init(locationData: JSON) {
    self.init(latitude: locationData[GoKeys.latitudeKey].doubleValue, longitude: locationData[GoKeys.longitudeKey].doubleValue)
  }
}
