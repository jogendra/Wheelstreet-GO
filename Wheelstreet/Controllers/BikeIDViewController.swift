//
//  BikeIDViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 14/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import PinCodeTextField
import CoreLocation

protocol BikeIDDelegate: class {
    func getBikeData(goBike: GoBike)
}

class BikeIDViewController: UIViewController {
    
    var bikeFareView = Bundle.main.loadNibNamed("BikeFareView", owner: self, options: nil)?.first as? BikeFareView

    weak var bikeIDDelegate: BikeIDDelegate?
    
    @IBOutlet weak var bikeIDTextView: PinCodeTextField! {
        didSet {
            bikeIDTextView.delegate = self
        }
    }
    
    var tappedBike: GoBike?
    var bikeId: Int?
    var bikeReading: GoReading?
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManagerSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        bikeIDTextView.becomeFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        bikeIDTextView.resignFirstResponder()
    }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.makeNavigationBarTransparent()
  }
    
    func locationManagerSetup() {
        // Ask for Authorisation from the User.
        locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func proceedBike(with bike: GoBike, reading: GoReading?) {
        if self.tappedBike != nil {
            let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .start, bookingID: nil, scannedBike: self.tappedBike!, reading: reading)
            enterKMVC.reading = reading
          UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
        }
        else {
            self.tappedBike = bike
           self.goToBikeFareView(bike: bike)
        }
    }
    
    func goToBikeFareView(bike: GoBike) {
        guard let bikeFareView = bikeFareView else {
            return
        }
        bikeFareView.layer.opacity = 0.4
        UIView.animate(withDuration: 0.3, animations: {
            bikeFareView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(bikeFareView)
            bikeFareView.bike = bike
            bikeFareView.bikeFareViewDelegate = self
            bikeFareView.layer.opacity = 1.0
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

extension BikeIDViewController: PinCodeTextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        let value = textField.text ?? ""
        textField.text = textField.text?.uppercased()
        
//        guard let currentLocation = currentLocation else {
//            return
//        }
        let params: [String : Any] =  ["source": 3, "regNo": value, "lat": 12.89515320, "lng": 77.60747970]
        if value.count > 9 {
            WheelstreetAPI.checkBike(params: params, completion: { goBike, parsedJSON, statusCode, error in
                if error != nil {
                    print(error as Any)
                    WheelstreetViews.bluredAlertView(title: "Error", message: "Please try again")
                    return
                } else {
                    switch statusCode {
                    case .SUCCESS:
                        guard let enteredBike = goBike else {
                            return
                        }
                        let bikeReadingData = parsedJSON?[GoKeys.data]["km"]
                        let reading = GoReading(data: bikeReadingData!)
                        self.bikeReading = reading
                        self.bikeIDDelegate?.getBikeData(goBike: enteredBike)
                        self.proceedBike(with: enteredBike, reading: reading)
                    case .FALIURE:
                        guard let responseError = parsedJSON?["error"].string else {
                            return
                        }
                        WheelstreetViews.alertView(title: "Alert", message: responseError)
                        self.bikeIDTextView.text = nil
                    default:
                        WheelstreetViews.alertView(title: "Alert", message: WheelstreetAPI.statusToMessage(statusCode))
                        self.bikeIDTextView.text = nil
                    }
                }
            })
        }
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}

extension BikeIDViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location
    }
}

extension BikeIDViewController: BikeFareViewDelegate {
  func didTapFareDetail(bike: GoBike) {
    let fareDetailsVC = FareDetailsViewController(nibName: "FareDetailsViewController", bundle: nil, bike: bike)
    UIApplication.navigationController().present(fareDetailsVC, animated: true, completion: nil)
  }

    func didTapProceed() {
        let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .start, bookingID: nil, scannedBike: self.tappedBike, reading: self.bikeReading)
        enterKMVC.reading = self.bikeReading
      UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
    }
    
    func didTapScanQR() {
         UIApplication.navigationController().popViewController(animated: true)
    }
}
