//
//  GOSafeLocation.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class GOSafeLocation: GOLocation {

  var title: String
  var distance: Double?

  init (locationTitle: String, data: JSON) {
    self.title = locationTitle
    self.distance = data[GoKeys.distanceKey].double

    super.init(latitude: data[GoKeys.paramLatitudeKey].doubleValue, longitude: data[GoKeys.paramLongitudeKey].doubleValue)
  }

}
