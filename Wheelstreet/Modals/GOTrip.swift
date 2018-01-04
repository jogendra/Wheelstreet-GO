//
//  GOTrip.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 26/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

class GOTrip: GOBooking {
    var orderId : Int
    var paymentStatus: GOPaymentStatus = .initiate

    required init(data: JSON, bike: GoBike? = nil, user: GoUser? = nil) {
        orderId = data["orderId"].object as! Int
        super.init(data: data, bike: bike, user: user)
    }

  init(orderId: Int, data: JSON, status: GOPaymentStatus, bike: GoBike? = nil, user: GoUser? = nil) {
    self.orderId = orderId
    self.paymentStatus = status
    super.init(data: data, bike: bike, user: user)
  }
}
