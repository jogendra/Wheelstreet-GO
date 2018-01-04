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

    let hString = hours >= 0 && 9 >= hours ? "0\(hours)" : "\(hours)"
    let mString = minutes >= 0 && 9 >= minutes ? "0\(minutes)" : "\(minutes)"
    let sString = seconds >= 0 && 9 >= seconds ? "0\(seconds)" : "\(seconds)"

    return hString + ":" + mString + ":" + sString
  }

  static func prettyStringFromTimeInterval(interval: Int) -> String {
    let hours = Int(interval/3600)
    let minutes = Int((interval%3600)/60)
    let seconds = Int((interval%3600)%60)

    var string = ""
    if hours >= 1 {
      let hString = minutes < 1 && seconds < 1 ? (hours == 1 ? "hour" : "hours") : "h"
      string += "\(hours) " + hString + " "
    }

    if minutes >= 1 {
      let mString = hours < 1 && seconds < 1 ? "min" : "m"
      string += "\(minutes) " + mString + " "
    }
    if seconds >= 1 && hours < 1 {
      let sString = minutes < 1 && hours < 1 ? "seconds" : "s"
      string += "\(seconds) " + sString
    }

    if string == "" {
      string = "1 min"
    }

    return string
  }



  static func googleMapsDirections(fromLocation: GOLocation? = nil, toLocation location: GOLocation, completionHandler completion: ((Bool) -> Swift.Void)? = nil, cancelationHandler cancelation: @escaping(() -> Swift.Void)) {

    let googleMapsURLScheme = "comgooglemaps://"
    let googleMapsAppURL = URL(string: googleMapsURLScheme)

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

    if UIApplication.shared.canOpenURL(googleMapsAppURL!) {
      UIApplication.shared.open(directionsURL, options: ["":""], completionHandler: completion)
    }
    else {
      WheelstreetViews.alertView(title: "Google Maps Not Installed", message: "Install Google Maps to Access GO")
    }
  }

  static func help() {
    var goCustomerCareMobileNumber = "+91-8088400500"

    if let helpline = UserDefaults.standard.value(forKey: GoKeys.help) as? String {
      goCustomerCareMobileNumber = helpline
    }
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
