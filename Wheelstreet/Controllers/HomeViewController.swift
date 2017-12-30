//
//  HomeViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 05/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire

fileprivate struct Defaults {
    static let wsLatitude = 12.9382828
    static let wsLongitude = 77.6237627
    static let zoomLevel: Float = 16.0
}

protocol HomeStatusBarDelegate: class {
    func didChangeUserStatus(homeUserStatus: UserStatus)
}

class HomeViewController: UIViewController {
    
    var goMapView: GoMapView?
    
    var goBike: [GoBike] = []
    
    var selectedPlace: GMSPlace?
    
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocation?
    
    var didFindMyLocation = false
    
    var goPullUpView: GoPullUpView = {
      if let view = Bundle.main.loadNibNamed("GoPullUpView", owner: self, options: nil)?.first as? GoPullUpView {
        return view
      }
      else {
        fatalError("Unable to Load GoPullUpView from nib")
      }
    }()

    var fareDetailsView = Bundle.main.loadNibNamed("FareDetailsView", owner: self, options: nil)?.first as? FareDetailsView
    
    var statusBarView = Bundle.main.loadNibNamed("StatusBarView", owner: self, options: nil)?.first as? StatusBarView
    
    let defaultLocation: CLLocation = CLLocation(latitude: Defaults.wsLatitude, longitude: Defaults.wsLongitude)
    
    var userProfileView = Bundle.main.loadNibNamed("UserProfileView", owner: self, options: nil)?.first as? UserProfileView
    
    var userAuthStatus: UserStatus?
    
    var isPullViewPresented: Bool = false
    
    let refreshButton = GoButtons.refreshButton
    
    let unlockButton = GoButtons.unlockButton
    
    let userButton = GoButtons.userButton
    
    let customerCareButton = GoButtons.customerCareButton
    
    let customMyLocationButton = GoButtons.customMyLocationButton
    
    var path = GMSMutablePath()
    
    let polyline = GMSPolyline()
    
    var scannedViewController: ScannerViewController?
    
    weak var homeStatusBarDelegate: HomeStatusBarDelegate?
    
    var blurLayer: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        addMapView()
      
        WheelstreetAPI.checkUser()
        getAllBikesLocations()
        setupStatusBarView()
        setupLayoutForButtons()
        showFareDetailsView()
        customMyLocationButton.addTarget(self, action: #selector(goToMyCurrentLocation(_:)), for: .touchUpInside)
        addPullUpView()
        addTargetsToButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
        self.goMapView?.removeObserver(self, forKeyPath: "myLocation")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.navigationController?.isNavigationBarHidden = true
        goMapView?.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
        HandleUserStatusBar()
    }
    
    func addTargetsToButtons() {
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
      unlockButton.addTarget(self, action: #selector(didTapUnlock), for: .touchUpInside)

        customMyLocationButton.addTarget(self, action: #selector(goToMyCurrentLocation(_:)), for: .touchUpInside)
        userButton.addTarget(self, action: #selector(userButtonTapped(_:)), for: .touchUpInside)
        customerCareButton.addTarget(self, action: #selector(didTapCallCustomerCare(_:)), for: .touchUpInside)
    }


    @objc func didTapUnlock() {
      self.navigationController?.isNavigationBarHidden = false
      if let scannerVC = UIStoryboard.scannerVC() as? ScannerViewController {
        scannerVC.tappedBike = nil
        self.navigationController?.pushViewController(scannerVC, animated: true)
      }
    }
    
    @objc func didTapCallCustomerCare(_ sender: Any) {
      let  goCustomerCareMobileNumber = "+91-7338-259-460"
        guard let numberURL = URL(string: "tel://" + goCustomerCareMobileNumber) else { return }
        UIApplication.shared.open(numberURL)
        
    }

  func didTapUnlockFor(bike: GoBike) {
    self.navigationController?.isNavigationBarHidden = false
    if let scannerVC = UIStoryboard.scannerVC() as? ScannerViewController {
        scannerVC.tappedBike = bike
      self.navigationController?.pushViewController(scannerVC, animated: true)
    }
  }
    
    @objc func userButtonTapped(_ sender: Any) {
        addBlurViewLayer()
        guard let userProfileView = userProfileView else {
            return
        }
        userProfileView.userProfileDelegate = self
        userProfileView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        userProfileView.layer.opacity = 0.0
        blurLayer?.layer.opacity = 0.0
        
        UIView.animate(withDuration: 0.2, animations: {
            userProfileView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 66.0)
            self.blurLayer?.addSubview(userProfileView)
            
            userProfileView.layer.opacity = 0.4
            self.blurLayer?.layer.opacity = 0.4
        }, completion: { (true) in
            UIView.animate(withDuration: 0.1, animations: {
                userProfileView.layer.opacity = 0.7
                self.blurLayer?.layer.opacity = 0.7
            }, completion: { (true) in
                userProfileView.layer.opacity = 1.0
                self.blurLayer?.layer.opacity = 1.0
                userProfileView.layer.cornerRadius = 0.0
                self.customMyLocationButton.isHidden = true
            })
        })
    }
    
    func addBlurViewLayer() {
        blurLayer = UIView()
        guard let blurLayer = blurLayer else {
            return
        }
        blurLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        UIView.animate(withDuration: 0.3, animations: {
            blurLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            visualEffectView.frame = blurLayer.frame
            blurLayer.addSubview(visualEffectView)
            self.view.addSubview(blurLayer)
            self.view.addSubview(self.unlockButton)
            self.view.addSubview(self.customerCareButton)
        })
    }
    
    func HandleUserStatusBar() {
        let isUserLoggedIn = UserDefaults.standard.bool(forKey: GoKeys.isUserLoggedIn)
        if !isUserLoggedIn {
            statusBarView?.userStatus = .notLoggedIn
            homeStatusBarDelegate?.didChangeUserStatus(homeUserStatus: .notLoggedIn)
        } else {
            
        }
    }
    
    func addMapView() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        let defaultCamera = GMSCameraPosition.camera(withLatitude: Defaults.wsLatitude, longitude: Defaults.wsLongitude, zoom: Defaults.zoomLevel)
        
        goMapView = GoMapView(frame: view.frame, goCamera: defaultCamera)
        
        goMapView?.settings.myLocationButton = false
        goMapView?.settings.compassButton = true
        goMapView?.goDelegate = self
        goMapView?.animate(toZoom: Defaults.zoomLevel)
        
        
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: Defaults.wsLatitude, longitude: Defaults.wsLongitude))
        marker.icon =  UIImage(named: GoImages.goMarkerIcon)
        
        guard let goMapView = goMapView else {
            return
        }
        
        goMapView.isMyLocationEnabled = true
        
        view.addSubview(goMapView)
        goMapView.translatesAutoresizingMaskIntoConstraints = false
        goMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        goMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        goMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        goMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        guard let currentLocation = goMapView.myLocation else {
            return
        }
        
        let updatedCamera = GMSCameraUpdate.setTarget(currentLocation.coordinate, zoom: Defaults.zoomLevel)
        goMapView.moveCamera(updatedCamera)
        
        marker.position = currentLocation.coordinate
        marker.map = goMapView
        marker.icon =  UIImage(named: GoImages.goMarkerIcon)
    }
    
    fileprivate func getAllBikesLocations() {
        WheelstreetAPI.getAllBikeLocation(completion: { goBikes, statusCode in
            guard let goBikes = goBikes else {
                return
            }
            self.goBike = goBikes
            for bike in goBikes {
                self.markBikePlace(latitude: (bike.location?.latitude)!, langitude: (bike.location?.longitude)!)
            }
        })
    }
    
    fileprivate func markBikePlace(latitude: Double, langitude: Double) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: langitude)
        marker.icon =  UIImage(named: GoImages.goMarkerIcon)
        marker.map = goMapView
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            self.goMapView?.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: Defaults.zoomLevel)
            didFindMyLocation = true
        }
    }
    
    func setupLayoutForButtons() {
        
        // User Button setup
        view.addSubview(userButton)
        
        guard let statusBarView = statusBarView else {
            return
        }
        userButton.translatesAutoresizingMaskIntoConstraints = false
        userButton.topAnchor.constraint(equalTo: statusBarView.bottomAnchor, constant: GoButtons.userbuttonTopAnchorConstant).isActive = true
        userButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GoButtons.userButtonLeadingAnchorConstant).isActive = true
        userButton.heightAnchor.constraint(equalToConstant: GoButtons.userButtonHeight).isActive = true
        userButton.widthAnchor.constraint(equalToConstant: GoButtons.userButtonWidth).isActive = true
        
        // Help Buttuon setup
        let helpButton = GoButtons.helpButton
        view.addSubview(helpButton)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.centerYAnchor.constraint(equalTo: userButton.centerYAnchor).isActive = true
        helpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -GoButtons.userButtonLeadingAnchorConstant).isActive = true
        helpButton.heightAnchor.constraint(equalTo: userButton.heightAnchor).isActive = true
        helpButton.widthAnchor.constraint(equalTo: userButton.widthAnchor).isActive = true
        
        // Customer Service Button setup
        view.addSubview(customerCareButton)
        customerCareButton.translatesAutoresizingMaskIntoConstraints = false
        customerCareButton.centerXAnchor.constraint(equalTo: userButton.centerXAnchor).isActive = true
        customerCareButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: GoButtons.customerCareButtonBottomAnchorConstant).isActive = true
        customerCareButton.heightAnchor.constraint(equalTo: userButton.heightAnchor).isActive = true
        customerCareButton.widthAnchor.constraint(equalTo: userButton.widthAnchor).isActive = true
        
        // Refresh Button setup
        view.addSubview(refreshButton)
        self.refreshButton.translatesAutoresizingMaskIntoConstraints = false
        self.refreshButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -GoButtons.userButtonLeadingAnchorConstant).isActive = true
        self.refreshButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: GoButtons.refreshButtonBottomAnchorConstant).isActive = true
        self.refreshButton.heightAnchor.constraint(equalTo: userButton.heightAnchor).isActive = true
        self.refreshButton.widthAnchor.constraint(equalTo: userButton.widthAnchor).isActive = true
        
        // Unlock Button setup
        view.addSubview(unlockButton)
        self.unlockButton.translatesAutoresizingMaskIntoConstraints = false
        self.unlockButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.unlockButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: GoButtons.customerCareButtonBottomAnchorConstant).isActive = true
        self.unlockButton.heightAnchor.constraint(equalToConstant: GoButtons.unlockButtonHeight).isActive = true
        self.unlockButton.widthAnchor.constraint(equalToConstant: GoButtons.unlockButtonWidth).isActive = true
        
        // Custom My Location Button setup
        view.addSubview(customMyLocationButton)
        self.customMyLocationButton.translatesAutoresizingMaskIntoConstraints = false
        self.customMyLocationButton.centerYAnchor.constraint(equalTo: customerCareButton.centerYAnchor).isActive = true
        self.customMyLocationButton.centerXAnchor.constraint(equalTo: helpButton.centerXAnchor).isActive = true
        self.customMyLocationButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: GoButtons.customerCareButtonBottomAnchorConstant).isActive = true
    }
    
    
    fileprivate func addPullUpView() {
        goPullUpView.frame = CGRect(x: 15.0, y: view.frame.height - goPullUpView.frame.height - 15.0, width: view.frame.width - 30.0, height: goPullUpView.frame.height)
        view.addSubview(goPullUpView)
        goPullUpView.pullViewDelegate = self
        goPullUpView.isHidden = true
    }
    
    fileprivate func showFareDetailsView() {
        guard let fareDetailsView = fareDetailsView else {
            return
        }
        
        fareDetailsView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: fareDetailsView.frame.height)
        view.addSubview(fareDetailsView)
        fareDetailsView.isHidden = false
    }
    
  fileprivate func updatePullUpView(present: Bool, bike: GoBike? = nil) {
    goPullUpView.isHidden = !present

    if let bike = bike {
      goPullUpView.bike = bike
    }
    // Remove the previous drawed line
    polyline.map = nil
    // Add pull view to map
    goPullUpView.transform = CGAffineTransform(translationX:0, y: present ? goPullUpView.bounds.height : 2*goPullUpView.bounds.height)
    GoPullUpView.animate(withDuration: 0.3, animations: {
      self.goPullUpView.transform = CGAffineTransform.identity
      GoButtons.customerCareButton.isHidden = present
      self.unlockButton.isHidden = present
      self.refreshButton.isHidden = present
      self.customMyLocationButton.isHidden = present
    }, completion: { (cancelled) in
      self.isPullViewPresented = present
    })
  }

    fileprivate func setupStatusBarView() {
        
        guard let statusBarView = statusBarView else {
            return
        }
        statusBarView.statusBarDelegate = self
        view.addSubview(statusBarView)
        statusBarView.translatesAutoresizingMaskIntoConstraints = false
        statusBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        statusBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        statusBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statusBarView.heightAnchor.constraint(equalToConstant: 64.0).isActive = true
    }
    
    @objc func refreshButtonTapped(_ sender: Any) {
        //        guard let myLocationCoordinate = currentLocation?.coordinate else {
        //            return
        //        }
        let myLoactionCamera = GMSCameraPosition.camera(withTarget: defaultLocation.coordinate, zoom: Defaults.zoomLevel)
        let updatedCamera = GMSCameraUpdate.setTarget(defaultLocation.coordinate, zoom: Defaults.zoomLevel)
        goMapView?.camera = myLoactionCamera
        goMapView?.animate(to: myLoactionCamera)
        goMapView?.moveCamera(updatedCamera)
    }

    @objc func goToMyCurrentLocation(_ sender: Any) {
        guard let lat = self.goMapView?.myLocation?.coordinate.latitude,
            let lng = self.goMapView?.myLocation?.coordinate.longitude else { return }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng , zoom: Defaults.zoomLevel)
        self.goMapView?.animate(to: camera)
    }
    
}


extension HomeViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let goMapView = goMapView, let currentLocation = locations.last else {
            return
        }
        
        self.currentLocation = currentLocation
        
        let currentLocationCamera = GMSCameraPosition.camera(
            withLatitude: currentLocation.coordinate.latitude,
            longitude: currentLocation.coordinate.longitude,
            zoom: Defaults.zoomLevel)
        
        goMapView.camera = currentLocationCamera
        goMapView.animate(to: currentLocationCamera)
        
    }
    
}


extension HomeViewController: GoMapViewDelegate {
    
    func didTapMarker(_ mapView: GMSMapView, didTap marker: GMSMarker) {
        let tappedPosition = marker.position
        let tappedLatitude = tappedPosition.latitude
        
        let filteredBike = goBike.filter { $0.location?.latitude == tappedLatitude }
        
        if filteredBike.count > 0 {
          updatePullUpView(present: true, bike: filteredBike[0])
        }
        let tappedBikeLocation = CLLocation(latitude: (filteredBike[0].location?.latitude)!, longitude: (filteredBike[0].location?.longitude)!)
        
        drawPath(destinationLocation: tappedBikeLocation)
    }
    
    func didTapOnMap(_ mapView: GMSMapView) {
      updatePullUpView(present: false)
    }
    
    func drawPath(destinationLocation: CLLocation) {
        let originLocation = CLLocation(latitude: Defaults.wsLatitude, longitude: Defaults.wsLongitude)
        let origin = "\(originLocation.coordinate.latitude),\(originLocation.coordinate.longitude)"
        let destination = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking"
        
        Alamofire.request(url).responseJSON { response in
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                self.polyline.path = path
                self.polyline.strokeColor = UIColor(red: 25.0/255.0, green: 206.0/255.0, blue: 145.0/255.0, alpha: 1.0)
                self.polyline.strokeWidth = 5.0
                self.polyline.map = self.goMapView
            }
            }.resume()
    }
}

extension HomeViewController: StatusBarViewDelegate {
    func didTappedStatusBarActionButton() {
        
    }
}

extension HomeViewController: UserProfileDelegate {
    func didTapMapButton() {
        self.userProfileView?.layer.opacity = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            self.userProfileView?.layer.opacity = 0.0
            self.userProfileView?.removeFromSuperview()
            self.blurLayer?.removeFromSuperview()
            self.customMyLocationButton.isHidden = false
        })
    }
}

extension HomeViewController: GoPullUpViewDelegate {
  func presentFareDetailsFor(bike: GoBike) {
    let fareDetailsVC = FareDetailsViewController(nibName: "FareDetailsViewController", bundle: nil, bike: bike)
    UIApplication.topViewController()?.present(fareDetailsVC, animated: true, completion: nil)
  }

  func didTapUnlockButtonFor(bike: GoBike) {
    self.didTapUnlockFor(bike: bike)
  }


}
