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

    required init(data: JSON, bike: GoBike? = nil, user: GoUser? = nil) {
        orderId = data["orderId"].object as! Int
        super.init(data: data, bike: bike, user: user)
    }
}
