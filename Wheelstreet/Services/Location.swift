//
//  Location.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 26/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class Location: NSObject {
    static let shared = Location()

  override init() {
    super.init()

    locationManagerSetup()
  }
    
    let locationManager = CLLocationManager()
    public var currentLocation: CLLocation?
    
    func locationManagerSetup() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self as? CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
   func userCurrentLocation() -> CLLocation? {
      return currentLocation
  }
}

extension Location: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = manager.location
    }
}
