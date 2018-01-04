//
//  GoUserDefaultsService.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation
import CoreLocation
import Mixpanel

public class GoUserDefaultsService {

  class func set(login: Bool) {
    UserDefaults.standard.set(login, forKey: GoKeys.isUserLoggedIn)
  }

    class func clearUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: GoKeys.accessToken)
        defaults.removeObject(forKey: GoKeys.email)
        defaults.removeObject(forKey: GoKeys.mobileNumber)
        defaults.removeObject(forKey: GoKeys.userOTP)
        defaults.removeObject(forKey: GoKeys.kycStatus)
        defaults.removeObject(forKey: GoKeys.username)
        defaults.removeObject(forKey: GoKeys.userId)
        defaults.removeObject(forKey: GoKeys.userRole)
        defaults.removeObject(forKey: GoKeys.name)
        defaults.synchronize()
    }
    
    class func setUserData(for goUser: GoUser) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: GoKeys.isUserLoggedIn)
        defaults.set(goUser.userAccessToken!, forKey: GoKeys.accessToken)
        defaults.set(goUser.userID!, forKey: GoKeys.userId)
        defaults.set(goUser.userRole!, forKey: GoKeys.userRole)
        defaults.set(goUser.name!, forKey: GoKeys.name)
        defaults.set(goUser.mobile!, forKey: GoKeys.mobileNumber)
        defaults.set(goUser.email!, forKey: GoKeys.email)
        defaults.set(goUser.username!, forKey: GoKeys.username)
        defaults.synchronize()

      let mixpanel = Mixpanel.mainInstance()
      mixpanel.createAlias("\(goUser.userRole!)", distinctId: mixpanel.distinctId)
      mixpanel.identify(distinctId: mixpanel.distinctId)
      mixpanel.people.set(properties: [GoKeys.name: goUser.name!,
                                       GoKeys.mobileNumber: goUser.mobile!,
                                       GoKeys.email: goUser.email!,
                                       GoKeys.username: GoKeys.username])
      if let lat = UserDefaults.standard.value(forKey: GoKeys.currentLat) as? CLLocationDegrees, let lng = UserDefaults.standard.value(forKey: GoKeys.currentLng) as? CLLocationDegrees {
        mixpanel.registerSuperProperties(["lat": Double(lat),"lng": Double(lng)])
      }
    }

  class func currentLocationCordinate() -> CLLocationCoordinate2D {
    guard let lat = UserDefaults.standard.value(forKey: GoKeys.currentLat) as? Double, let lng = UserDefaults.standard.value(forKey: GoKeys.currentLng) as? Double else {
      Location.shared.locationManagerSetup()
      return retryCurrentLocationCordinate()
    }
    return CLLocationCoordinate2D(latitude: lat, longitude: lng)
  }

  class func retryCurrentLocationCordinate() -> CLLocationCoordinate2D {
    guard let lat = UserDefaults.standard.value(forKey: GoKeys.currentLat) as? Double, let lng = UserDefaults.standard.value(forKey: GoKeys.currentLng) as? Double else {
      Location.shared.locationManagerSetup()
      return CLLocationCoordinate2D(latitude: 12.19864, longitude: 77.7044041)
    }
    return CLLocationCoordinate2D(latitude: lat, longitude: lng)
  }

    
    class func setProfileData(for goUser: GoUser) {
        let defaults = UserDefaults.standard
        defaults.set(goUser.bookingCount, forKey: GoKeys.bookingCount)
        defaults.set(goUser.distance, forKey: GoKeys.distanceKey)
        defaults.set(goUser.kycStatus, forKey: GoKeys.kycStatus)
        defaults.synchronize()
    }
}
