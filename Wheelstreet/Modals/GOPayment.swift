//
//  GOPayment.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 26/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

enum GOPaymentMode: String {
  case paytm = "Paytm"
}

class GOPayment {
  var paymentMode: GOPaymentMode
  var amount: String
  var addedOn: Date?

  init(paymentMode: GOPaymentMode, amount: String, addedOn: Date?) {
    self.paymentMode = paymentMode
    self.amount = amount
    self.addedOn = addedOn
  }

  convenience init(data: JSON) {
    self.init(paymentMode: GOPaymentMode(rawValue: data["GOPaymentMode"].string ?? "Paytm") ?? .paytm,
              amount: data["amount"].stringValue,
              addedOn: WheelstreetCommon.ddMMyyyyDateTimeFormatter.date(from: data["addedOn"].stringValue))
  }
}
