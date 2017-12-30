//
//  GoUser.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation


enum UserStatus: Int {
  case notLoggedIn = -3
  case rejected = -1
  case underVerification = 0
  case verified = 1
  case notUploaded = 2
  case none = -4
}


class GoUser {
    var userAccessToken: String?
    var userID: Int?
    var userRole: Int?
    var name: String?
    var mobile: String?
    var email: String?
    var username: String?
    var bookingCount: Int?
    var distance: Int?
    var kycStatus: String?
    
    init(accessToken: String?, userID: Int?, userRole: Int?, name: String?, mobile: String?, email: String?, username: String?, bookingCount: Int?, distance: Int?, kycStatus: String?) {
        self.userAccessToken = accessToken
        self.userID = userID
        self.userRole = userRole
        self.name = name
        self.mobile = mobile
        self.email = email
        self.username = username
        self.bookingCount = bookingCount
        self.distance = distance
        self.kycStatus = kycStatus
    }
    
    convenience init(data: JSON) {
        guard let userID = data[GoKeys.userId].int, let name = data[GoKeys.name].string, let mobile =  data[GoKeys.mobileNumber].string, let email = data[GoKeys.email].string else {
            fatalError("User is not initialized")
        }

      let accessToken = data[GoKeys.accessToken].string ?? Utils().checkNSUserDefault(GoKeys.accessToken)
      var userRole: Int?

      if let userRoleData = data[GoKeys.userRole].object as? Int {
        userRole = userRoleData
      }

      let username = data[GoKeys.username].string

      self.init(accessToken: accessToken, userID: userID, userRole: userRole, name: name, mobile: mobile, email: email, username: username, bookingCount: data[GoKeys.bookingCount].string?.toInt(), distance: data[GoKeys.distanceKey].string?.toInt(), kycStatus: data[GoKeys.kycStatus].string)
    }
    
    convenience init(data: JSON, forProfile: Bool) {
        guard let name = data[GoKeys.name].string, let bookingCount = data[GoKeys.bookingCount].int, let kycStatus = data[GoKeys.kycStatus].string, let mobile = data[GoKeys.mobileNumber].string, let distance = data[GoKeys.distanceKey].int
            else {
                fatalError("User is not initialized")
        }
        
        let defaults = UserDefaults.standard
        
        let accessToken = defaults.value(forKey: GoKeys.accessToken)
        let userID = defaults.value(forKey: GoKeys.userId) as? Int
        let userRole = defaults.value(forKey: GoKeys.userRole) as? Int
        let email = defaults.value(forKey: GoKeys.email)
        let username = defaults.value(forKey: GoKeys.username)
        
        self.init(accessToken: String(describing: accessToken), userID: userID, userRole: userRole, name: name, mobile: mobile, email: String(describing: email), username: String(describing: username), bookingCount: bookingCount, distance: distance, kycStatus: kycStatus)
        
    }

  class func convertKYCStatus(userStatus: UserStatus) -> String {
    switch userStatus {
    case .verified:
      return "Verified"
    case .rejected:
      return "Rejected"
    case .underVerification:
      return "Under Verification"
    case .notUploaded:
      return "Not Applied"
    default:
      return ""
    }
  }
}
