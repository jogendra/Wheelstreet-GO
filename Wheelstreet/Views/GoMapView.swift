//
//  GoogleMapView.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 05/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

protocol GoMapViewDelegate: class {
    func didTapMarker(_ mapView: GMSMapView, didTap marker: GMSMarker)
    func didTapOnMap(_ mapView: GMSMapView)
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker)
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker)
}

class GoMapView: GMSMapView {

    weak var goDelegate: GoMapViewDelegate?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!

    // An array to hold the list of likely places where bikes are available.
    var likelyPlaces: [GMSPlace] = []
    var bikeLocations: [CLLocation] = []
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    init(frame: CGRect, goCamera: GMSCameraPosition) {
        super.init(frame: frame)
        
        camera = goCamera
        settings.myLocationButton = true
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        isMyLocationEnabled = true
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GoMapView: GMSMapViewDelegate {

  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    goDelegate?.didTapMarker(mapView, didTap: marker)
    return true
  }
    
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    goDelegate?.didTapOnMap(mapView)
  }

  func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    goDelegate?.mapView(mapView, didEndDragging: marker)
  }

  func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    goDelegate?.mapView(mapView, didBeginDragging: marker)
  }
}

