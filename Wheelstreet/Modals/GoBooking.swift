//
//  GoBooking.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 24/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation

enum GOBookingStatus: String {
  case booked = "Booked"
  case complete = "Completed"
  case paymentSuccess = "Payment Success"
  case paymentFailed = "Payment Failed"
  case paymentSkip = "Payment Skip"
}

class GOBooking {
  var bookingId : Int
  var bike : GoBike
  var pin : String?
  var user: GoUser
  var netAmount : String?
  var taxAmount : String?
  var totalAmount : String?
  var withoutDiscount : String?
  var startDateTime : Int?
  var startDate: Date?
  var endDateTime : Int?
  var bookedOn : String?
  var startKm : Int?
  var endKm : Int?
  var bookingStatus : GOBookingStatus?
  var paymentDetails: [JSON]?
  var rent: [GORent]?
  var onGoingDuration : String?
  var minuteOffer : Int?
  var safeLocations: [GOSafeLocation] = []
  var documents: [String: URL]?


  required init(data: JSON, bike: GoBike? = nil, user: GoUser? = nil) {
    bookingId = data["bookingId"].object as! Int
    pin = data["pin"].object as? String
    self.user = user ?? GoUser(data: data)
    self.bike = bike ?? GoBike(data: data)
    if let netAmountData = data["netAmount"].object as? String {
      netAmount = netAmountData
    }
    if let taxAmountData = data["taxAmount"].object as? String {
      taxAmount = taxAmountData
    }
    if let totalAmountData = data["totalAmount"].object as? String {
      totalAmount = totalAmountData
    }
    if let withoutDiscountData = data["withoutDiscount"].object as? String {
      withoutDiscount = withoutDiscountData
    }
    if let startDateTimeString = data["startDateTime"].string {
      let date = WheelstreetCommon.ddMMyyyyDateTimeFormatter.date(from: startDateTimeString)
      self.startDate = date
      self.startDateTime = Int((date?.timeIntervalSince1970)!)
    }
    if let endDateTimeString = data["endDateTime"].string {
      let date = WheelstreetCommon.ddMMyyyyDateTimeFormatter.date(from: endDateTimeString)
      self.endDateTime = Int((date?.timeIntervalSince1970)!)
    }
    if let bookedOnData = data["bookedOn"].object as? String {
      bookedOn = bookedOnData
    }

    if let startKmData = data["startKm"].object as? Int {
      startKm = startKmData
    }
    if let endKmData = data["endKm"].object as? Int {
      endKm = endKmData
    }
    bookingStatus = GOBookingStatus(rawValue: data["bookingStatus"].string ?? "Booked")
    paymentDetails = data["paymentDetails"].array
    if let rentData = data["rent"].dictionary  {
      rent = [GORent]()
      for (key, value) in rentData {
        let goRent = GORent(typeString: key, data: value)
        rent?.append(goRent)
      }
    }
    onGoingDuration = data["onGoingDuration"].string
    if let minuteOfferData = data["minuteOffer"].object as? Int {
      minuteOffer = minuteOfferData
    }
    for (key, value) in data["safeLocation"] {
      let location = GOSafeLocation(locationTitle: key, data: value)
      self.safeLocations.append(location)
    }

    if let documentsData = data["documents"].dictionary {
      self.documents = [:]
      for (key, value) in documentsData {
        if let value = value.object as? String, let url = URL(string: value) {
          self.documents![key] = url
        }
      }
    }
  }
  
}

