//
//  WheelstreetCommon.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 03/08/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import SafariServices


class WheelstreetCommon {

  static public var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  static public var yyyyMMdddateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dddd"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  static public var yyyyMMddDateTimeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dddd HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  static public var ddMMyyyyDateTimeFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy h:mm a"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    return dateFormatter
  }()

  static public var dayTimedateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }()

  static public func dateFormatterWithFormat(_ format: String) -> DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter
  }

  static func convertToTimeStamp(_ time: String, date: Date) -> Int? {
    if let timeStamp = yyyyMMddDateTimeFormatter.date(from: ("\(date.year)-\(date.month)-\(date.day)" + " " + time))?.timeIntervalSince1970 {
      return Int(timeStamp)
    }
    return nil
  }

  static func stringFromTimeInterval(interval: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: interval)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter.string(from: date)
  }

  static func timerStringFromTimeInterval(interval: Int) -> String {
    let hours = Int(interval/3600)
    let minutes = Int((interval%3600)/60)
    let seconds = Int((interval%3600)%60)

    return "\(hours):\(minutes):\(seconds)"
  }

  static func prettyStringFromTimeInterval(interval: TimeInterval, date: Date) -> String {
    let date = Date(timeInterval: interval, since: date)
    let dateFormatter = DateFormatter()
    if interval/3600 >= 1 {
      dateFormatter.dateFormat = "HH 'h' mm 'm'"
    }
    else {
      dateFormatter.dateFormat = "mm 'm' ss 's'"
    }
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    return dateFormatter.string(from: date)
  }



  static func googleMapsDirections(fromLocation: GOLocation? = nil, toLocation location: GOLocation, completionHandler completion: ((Bool) -> Swift.Void)? = nil, cancelationHandler cancelation: @escaping(() -> Swift.Void)) {

    let googleMapsURLScheme = "comgooglemaps://"

    guard let googleMapsAppURL = URL(string: googleMapsURLScheme),
      UIApplication.shared.canOpenURL(googleMapsAppURL)
      else {
        cancelation()
        return
    }

    var startingPoint = "saddr="
    if let fromLocation = fromLocation {
      startingPoint += "\(fromLocation.latitude),\(fromLocation.longitude)"
    }

    let destinationPoint = "daddr=\(location.latitude),\(location.longitude)"
    let directionsMode = "directionsmode=walking"

    guard let directionsURL = URL(string: googleMapsURLScheme.appending("?") + startingPoint.appending("&") + destinationPoint.appending("&") + directionsMode) else {
      cancelation()
      return
    }

    UIApplication.shared.open(directionsURL, options: ["":""], completionHandler: completion)
  }

  static func help() {
    let  goCustomerCareMobileNumber = "+91-7338-259-460"
    guard let numberURL = URL(string: "tel://" + goCustomerCareMobileNumber) else {
      WheelstreetViews.somethingWentWrongAlertView()
      return
    }
    UIApplication.shared.open(numberURL)
  }
  
  static func shareViaActivity() {
    let activityVC = UIActivityViewController(activityItems: [(URL(string: "https://mdg.sdslabs.co/appetizer") ?? "https://mdg.sdslabs.co/appetizer"), "Click the url to skip unwanted meals in the mess"], applicationActivities: nil)
      activityVC.completionWithItemsHandler = { (activity, success, items, error) in
      }

      UIApplication.topViewController()?.present(activityVC, animated: true, completion: nil)
  }
}
