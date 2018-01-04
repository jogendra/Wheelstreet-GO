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
import Mixpanel

fileprivate struct Defaults {
  static let zoomLevel: Float = 16.0
}

protocol HomeStatusBarDelegate: class {
  func didChangeUserStatus(homeUserStatus: UserStatus)
}

class HomeViewController: UIViewController, UINavigationControllerDelegate {

  var goMapView: GoMapView?

  var selectedPlace: GMSPlace?

  var locationManager = CLLocationManager()

  var didFindMyLocation = false

  var userStatus: UserStatus!

  var goPullUpView: GoPullUpView = {
    if let view = Bundle.main.loadNibNamed("GoPullUpView", owner: self, options: nil)?.first as? GoPullUpView {
      return view
    }
    else {
      fatalError("Unable to Load GoPullUpView from nib")
    }
  }()

  var userProfileView = Bundle.main.loadNibNamed("UserProfileView", owner: self, options: nil)?.first as? UserProfileView

  var userAuthStatus: UserStatus?

  var isPullViewPresented: Bool = false

  @IBOutlet var refreshButton: UIButton!
  @IBOutlet var unlockButton: UIButton!
  @IBOutlet var userButton: UIButton!
  @IBOutlet var helpButton: UIButton!
  @IBOutlet var customerCareButton: UIButton!
  @IBOutlet var customMyLocationButton: UIButton!

  @IBOutlet var userButtonshadowView: UIView!
  @IBOutlet var customerButtonshadowView: UIView!
  @IBOutlet var myLocationButtonshadowView: UIView!
  @IBOutlet var refreshButtonshadowView: UIView!

  @IBOutlet var userButtonTopConstraint: NSLayoutConstraint!
  
  @IBOutlet var unlockButtonConstraint: NSLayoutConstraint!
  var path = GMSMutablePath()

  let polyline = GMSPolyline()

  var scannedViewController: ScannerViewController?

  weak var homeStatusBarDelegate: HomeStatusBarDelegate?

  var blurLayer: UIView = UIView(frame: CGRect.zero)

  var goBikes: [GoBike]!
  
  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, bikes: [GoBike]?, userStatus: UserStatus) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.userStatus = userStatus
    if let bikes = bikes {
      self.goBikes = bikes
    }
    else {
      self.getAllBikeLocation()
    }

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = true

    addMapView()
    WheelstreetAPI.checkUser()
    setupLayoutForButtons()
    addPullUpView()
    if (goBikes) != nil {
      setMarkerToBikes()
    }
    addBlurViewLayer()
    blurView(isHidden: true)

    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goOpen)

    userButtonshadowView.clipsToBounds = false
    userButtonshadowView.layer.shadowColor = UIColor.black.cgColor
    userButtonshadowView.layer.shadowOpacity = 0.5
    userButtonshadowView.layer.shadowOffset = CGSize.zero
    userButtonshadowView.layer.shadowRadius = 10
    let shadowBounds = CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: userButtonshadowView.bounds.width - 10, height: userButtonshadowView.bounds.height - 10))
    userButtonshadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowBounds, cornerRadius: 24).cgPath

    customerButtonshadowView.clipsToBounds = false
    customerButtonshadowView.layer.shadowColor = UIColor.black.cgColor
    customerButtonshadowView.layer.shadowOpacity = 0.5
    customerButtonshadowView.layer.shadowOffset = CGSize.zero
    customerButtonshadowView.layer.shadowRadius = 10
    let customerButtonshadowBounds = CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: customerButtonshadowView.bounds.width - 10, height: customerButtonshadowView.bounds.height - 10))
    customerButtonshadowView.layer.shadowPath = UIBezierPath(roundedRect: customerButtonshadowBounds, cornerRadius: 24).cgPath

    myLocationButtonshadowView.clipsToBounds = false
    myLocationButtonshadowView.layer.shadowColor = UIColor.black.cgColor
    myLocationButtonshadowView.layer.shadowOpacity = 0.5
    myLocationButtonshadowView.layer.shadowOffset = CGSize.zero
    myLocationButtonshadowView.layer.shadowRadius = 10
    let myLocationButtonShadowBounds = CGRect(origin: CGPoint(x: 5, y: 5), size: CGSize(width: myLocationButtonshadowView.bounds.width - 10, height: myLocationButtonshadowView.bounds.height - 10))
    myLocationButtonshadowView.layer.shadowPath = UIBezierPath(roundedRect: myLocationButtonShadowBounds, cornerRadius: 24).cgPath

    refreshButtonshadowView.clipsToBounds = false
    refreshButtonshadowView.layer.shadowColor = UIColor.black.cgColor
    refreshButtonshadowView.layer.shadowOpacity = 0.5
    refreshButtonshadowView.layer.shadowOffset = CGSize.zero
    refreshButtonshadowView.layer.shadowRadius = 6
    let refreshButtonshadowBounds = CGRect(origin: CGPoint(x: 3, y: 3), size: CGSize(width: refreshButtonshadowView.bounds.width - 6, height: refreshButtonshadowView.bounds.height - 6))
    refreshButtonshadowView.layer.shadowPath = UIBezierPath(roundedRect: refreshButtonshadowBounds, cornerRadius: 18).cgPath

    helpButton.isHidden = true

    // Checks if it is iPhone X
    let isiPhoneX = UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
    unlockButtonConstraint.constant = isiPhoneX ? -20 : -40

    self.unlockButton.isHidden = false
    self.customerCareButton.isHidden = false
    self.navigationController?.isNavigationBarHidden = true
    UIApplication.navigationController().isNavigationBarHidden = true
  }

  //MARK: View Methods

  func addBlurViewLayer() {
    blurLayer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.view.frame.height + 300))
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.regular)
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    blurLayer.frame = CGRect(x: 0, y: 0, width: blurLayer.frame.width, height: blurLayer.frame.height)
    visualEffectView.frame = blurLayer.frame
    blurLayer.addSubview(visualEffectView)
    blurLayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMap)))
    self.view.insertSubview(blurLayer, belowSubview: self.unlockButton)
  }

  func blurView(isHidden: Bool) {
    blurLayer.isHidden = isHidden
    goButtonsHidden(isHide: !isHidden)
  }

  func addMapView() {
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    locationManager.distanceFilter = 50
    locationManager.startUpdatingLocation()

    let defaultCamera = GMSCameraPosition.camera(withLatitude: GoUserDefaultsService.currentLocationCordinate().latitude, longitude: GoUserDefaultsService.currentLocationCordinate().longitude, zoom: Defaults.zoomLevel)

    goMapView = GoMapView(frame: view.frame, goCamera: defaultCamera)

    goMapView?.settings.myLocationButton = false
    goMapView?.settings.compassButton = true
    goMapView?.goDelegate = self
    goMapView?.animate(toZoom: Defaults.zoomLevel)

    goMapView?.mapStyle(withFilename: "GoogleMapStyle", andType: "json")

    guard let goMapView = goMapView else {
      return
    }

    goMapView.isMyLocationEnabled = true

    view.insertSubview(goMapView, at: 0)
    goMapView.translatesAutoresizingMaskIntoConstraints = false

    if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
      // Checks if it is iPhone X
      goMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 18).isActive = true
    }
    else {
      goMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -18).isActive = true
    }
    goMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    goMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    goMapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    
    guard let currentLocation = goMapView.myLocation else {
      return
    }

    let updatedCamera = GMSCameraUpdate.setTarget(currentLocation.coordinate, zoom: Defaults.zoomLevel)
    goMapView.moveCamera(updatedCamera)
    goMapView.setNeedsDisplay()
  }

  fileprivate func setMarkerToBikes() {
    for bike in goBikes {
      self.markBikePlace(latitude: (bike.location?.latitude)!, langitude: (bike.location?.longitude)!)
    }
  }

  /*
  func addTargetsToButtons() {
    refreshButton.addTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
    unlockButton.addTarget(self, action: #selector(didTapDriectUnlock), for: .touchUpInside)

    customMyLocationButton.addTarget(self, action: #selector(goToMyCurrentLocation(_:)), for: .touchUpInside)
    userButton.addTarget(self, action: #selector(didTapUserButton), for: .touchUpInside)
    customerCareButton.addTarget(self, action: #selector(didTapCallCustomerCare(_:)), for: .touchUpInside)
    helpButton.addTarget(self, action: #selector(didTapCallCustomerCare(_:)), for: .touchUpInside)
  }

  func removeTargets() {
    refreshButton.removeTarget(self, action: #selector(refreshButtonTapped(_:)), for: .touchUpInside)
    unlockButton.removeTarget(self, action: #selector(didTapDriectUnlock), for: .touchUpInside)

    customMyLocationButton.removeTarget(self, action: #selector(goToMyCurrentLocation(_:)), for: .touchUpInside)
    userButton.removeTarget(self, action: #selector(didTapUserButton), for: .touchUpInside)
    customerCareButton.removeTarget(self, action: #selector(didTapCallCustomerCare(_:)), for: .touchUpInside)
    helpButton.removeTarget(self, action: #selector(didTapCallCustomerCare(_:)), for: .touchUpInside)
  }
 */

  func didTapUnlockFor(bike: GoBike) {
    switch userStatus {
    case .notLoggedIn, .none:
      let splashScreen = UIStoryboard.splashNavigationScreen()
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.navigationController = UINavigationController(rootViewController: splashScreen)
      UIApplication.topViewController()!.present(appDelegate.navigationController!, animated: true, completion: nil)
    case .underVerification:
      WheelstreetViews.alertView(title: "Driving License is under Verification", message: "Please Try again after some time.")
    case .notUploaded, .rejected:
      WheelstreetViews.basicAlertView(title: "Driving License is Not Uploaded", message: "Please Upload your Driving License to unlock a bike", actionButtonTitle: "Upload", actionStyle: .default, extraActions: nil, handler: { (action) in
        WheelstreetViews.statusBarToDefault()
        let kycUploadScreen = GOKYCUploadViewController(nibName: "GOKYCUploadViewController", bundle: nil, type: .front)
        let navigationVC = UINavigationController(rootViewController: kycUploadScreen)
        UIApplication.navigationController().present(navigationVC, animated: true, completion: nil)
      }, cancelHandler: nil, isCancelDarker: false)
      break
    case .verified:
      let scannerVC = UIStoryboard.scannerVC() as? ScannerViewController
      scannerVC?.tappedBike = bike
      UIApplication.navigationController().pushViewController(scannerVC!, animated: true)
    default:
      WheelstreetViews.somethingWentWrongAlertView()
    }
  }

  @IBAction func didTapDriectUnlock(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goDirectUnlock)
    switch userStatus {
    case .notLoggedIn:
      let splashScreen = UIStoryboard.splashNavigationScreen()
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.navigationController = UINavigationController(rootViewController: splashScreen)
      UIApplication.topViewController()!.present(appDelegate.navigationController!, animated: true, completion: nil)
    case .underVerification:
      WheelstreetViews.alertView(title: "Driving License is under Verification", message: "Please Try again after some time.")
    case .notUploaded, .rejected:
      WheelstreetViews.basicAlertView(title: "Driving License is Not Uploaded", message: "Please Upload your Driving License to unlock a bike", actionButtonTitle: "Upload", actionStyle: .default, extraActions: nil, handler: { (action) in
        WheelstreetViews.statusBarToDefault()
        let kycUploadScreen = GOKYCUploadViewController(nibName: "GOKYCUploadViewController", bundle: nil, type: .front)
        let navigationVC = UINavigationController(rootViewController: kycUploadScreen)
        UIApplication.navigationController().present(navigationVC, animated: true, completion: nil)
      }, cancelHandler: nil, isCancelDarker: false)
      break
    case .verified:
      UIApplication.navigationController().pushViewController(UIStoryboard.scannerVC(), animated: true)
    default:
      WheelstreetViews.somethingWentWrongAlertView()
    }
  }

    @IBAction func didTapCallCustomerCare(_ sender: Any) {
      Mixpanel.mainInstance().track(event: GoMixPanelEvents.goCustomerSupport)
      WheelstreetCommon.help()
    }

  @IBAction func didTapHelpButton(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goInfo)
    WheelstreetCommon.help()
  }

  @IBAction func didTapUserButton(_ sender: Any) {
    if UserDefaults.standard.value(forKey: GoKeys.isUserLoggedIn) as? Bool == true {
        blurView(isHidden: false)
        guard let userProfileView = userProfileView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        userProfileView.userProfileDelegate = self
        userProfileView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        userProfileView.layer.opacity = 0.0
        blurLayer.layer.opacity = 0.0
        
        UIView.animate(withDuration: 0.2, animations: {
            userProfileView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 66.0)
            self.blurLayer.addSubview(userProfileView)
            userProfileView.layer.opacity = 0.4
            self.blurLayer.layer.opacity = 0.4
        }, completion: { (true) in
                userProfileView.layer.opacity = 1.0
                self.blurLayer.layer.opacity = 1.0
                userProfileView.layer.cornerRadius = 0.0
            })
      } else {
      let splashScreen = UIStoryboard.splashNavigationScreen()
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.navigationController = UINavigationController(rootViewController: splashScreen)
      UIApplication.topViewController()!.present( UIApplication.navigationController(), animated: true, completion: nil)
    }
  }

  @IBAction func refreshButtonTapped(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goNearestBikes)

    let randomBike = goBikes[Int(arc4random_uniform(UInt32(goBikes.count - 1)))]

    guard let latitude = randomBike.location?.latitude,let longitude = randomBike.location?.longitude, let lat = self.goMapView?.myLocation?.coordinate.latitude,
      let lng = self.goMapView?.myLocation?.coordinate.longitude else { return }

    let myLocationCordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    let bikeCordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

    /*
     let nearestBikes = goBikes.filter { (bike) -> Bool in
     guard let latitude = bike.location?.latitude,let longitude = bike.location?.longitude, let lat = self.goMapView?.myLocation?.coordinate.latitude,
     let lng = self.goMapView?.myLocation?.coordinate.longitude else { return false }

     let myLocationCordinate = CLLocation(latitude: lat, longitude: lng)
     let bikeCordinate = CLLocation(latitude: latitude, longitude: longitude)

     return bikeCordinate.distance(from: myLocationCordinate) < 2000
     }

     let nearestBikeCordinate = CLLocationCoordinate2D(latitude: (nearestBikes[0].location?.longitude)!, longitude: (nearestBikes[0].location?.latitude)!)
     */

    let myLoactionCamera = GMSCameraPosition.camera(withTarget: myLocationCordinate, zoom: Defaults.zoomLevel)
    let updatedCamera = GMSCameraUpdate.setTarget(bikeCordinate, zoom: Defaults.zoomLevel)
    goMapView?.camera = myLoactionCamera
    goMapView?.animate(to: myLoactionCamera)
    goMapView?.moveCamera(updatedCamera)
  }

  @IBAction func goToMyCurrentLocation(_ sender: Any) {
    guard let lat = self.goMapView?.myLocation?.coordinate.latitude,
      let lng = self.goMapView?.myLocation?.coordinate.longitude else { return }

    let camera = GMSCameraPosition.camera(withLatitude: lat ,longitude: lng , zoom: Defaults.zoomLevel)
    self.goMapView?.animate(to: camera)
  }

  //MARK: API Methods

  fileprivate func getAllBikeLocation() {
    WheelstreetAPI.getAllBikeLocation(completion: { goBikes, statusCode in
      guard let goBikes = goBikes else {
        WheelstreetViews.somethingWentWrongAlertView()
        return
      }

      self.goBikes = goBikes
      Mixpanel.mainInstance().track(event: GoMixPanelEvents.goGetBikes, properties: ["Bike Count": goBikes.count])
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


  func setupLayoutForButtons() {
    /*
    // User Button setup
    view.addSubview(userButton)
    userButton.translatesAutoresizingMaskIntoConstraints = false
    userButton.topAnchor.constraint(equalTo: view.topAnchor, constant: GoButtons.userbuttonTopAnchorConstant).isActive = true
    userButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: GoButtons.userButtonLeadingAnchorConstant).isActive = true
    userButton.heightAnchor.constraint(equalToConstant: GoButtons.userButtonHeight).isActive = true
    userButton.widthAnchor.constraint(equalToConstant: GoButtons.userButtonWidth).isActive = true

    // Help Buttuon setup
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


    // Unlock Button setup
    view.addSubview(unlockButton)
    self.unlockButton.translatesAutoresizingMaskIntoConstraints = false
    self.unlockButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    self.unlockButton.bottomAnchor.constraint(equalTo: customerCareButton.bottomAnchor).isActive = true
    self.unlockButton.heightAnchor.constraint(equalToConstant: GoButtons.unlockButtonHeight).isActive = true
    self.unlockButton.widthAnchor.constraint(equalToConstant: GoButtons.unlockButtonWidth).isActive = true

    // Custom My Location Button setup
    view.addSubview(customMyLocationButton)
    self.customMyLocationButton.translatesAutoresizingMaskIntoConstraints = false
    self.customMyLocationButton.centerYAnchor.constraint(equalTo: customerCareButton.centerYAnchor).isActive = true
    self.customMyLocationButton.centerXAnchor.constraint(equalTo: helpButton.centerXAnchor).isActive = true
    self.customMyLocationButton.bottomAnchor.constraint(equalTo: customerCareButton.bottomAnchor).isActive = true

    // Refresh Button setup
    view.addSubview(refreshButton)
    self.refreshButton.translatesAutoresizingMaskIntoConstraints = false
    self.refreshButton.centerXAnchor.constraint(equalTo: customMyLocationButton.centerXAnchor).isActive = true
    self.refreshButton.bottomAnchor.constraint(equalTo: customMyLocationButton.topAnchor, constant: GoButtons.refreshButtonBottomAnchorConstant).isActive = true
    self.refreshButton.heightAnchor.constraint(equalToConstant: GoButtons.refreshButtonWidth).isActive = true
    self.refreshButton.widthAnchor.constraint(equalToConstant: GoButtons.refreshButtonWidth).isActive = true
 */

  }

  fileprivate func addPullUpView() {
    goPullUpView.frame = CGRect(x: 8.0, y: view.frame.height - 183 - 8.0, width: view.frame.width - 16.0, height: 183)
    view.addSubview(goPullUpView)
    addConstraintsToPullUpView()
    goPullUpView.pullViewDelegate = self
    goPullUpView.isHidden = true
  }
    
  func addConstraintsToPullUpView() {
    goPullUpView.translatesAutoresizingMaskIntoConstraints = false
    goPullUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8.0).isActive = true
    goPullUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8.0).isActive = true
    goPullUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -28.0).isActive = true
    goPullUpView.heightAnchor.constraint(equalToConstant: 183.0).isActive = true
  }

  fileprivate func updatePullUpView(present: Bool, bike: GoBike? = nil) {
    goPullUpView.isHidden = !present

    if let bike = bike {
      goPullUpView.bike = bike
    }
    // Remove the previous drawed line
    polyline.map = nil
    // Add pull view to map
    goPullUpView.frame = CGRect(x: 8.0, y: view.frame.height - 183 - 28.0, width: view.frame.width - 16.0, height: 183)
    goPullUpView.transform = CGAffineTransform(translationX:0, y: present ? goPullUpView.bounds.height : 2*goPullUpView.bounds.height)

    GoPullUpView.animate(withDuration: 0.3, animations: {
      self.goPullUpView.translatesAutoresizingMaskIntoConstraints = true
      self.goPullUpView.transform = CGAffineTransform.identity
      self.addConstraintsToPullUpView()
      GoButtons.customerCareButton.isHidden = present
      self.unlockButton.isHidden = present
      self.refreshButton.isHidden = present
      self.customMyLocationButton.isHidden = present
      self.userButtonshadowView.isHidden = present
      self.refreshButtonshadowView.isHidden = present
      self.customerButtonshadowView.isHidden = present
      self.myLocationButtonshadowView.isHidden = present

    }, completion: { (cancelled) in
      self.isPullViewPresented = present
    })
  }

  func goButtonsHidden(isHide: Bool) {
    self.userButton.isHidden = isHide
    self.userButtonshadowView.isHidden = isHide
//    self.helpButton.isHidden = isHide
    self.refreshButton.isHidden = isHide
    self.refreshButtonshadowView.isHidden = isHide

    self.customMyLocationButton.isHidden = isHide
    self.customerButtonshadowView.isHidden = isHide
    self.myLocationButtonshadowView.isHidden = isHide
  }

  @objc func didTapMap() {
    self.userProfileView?.removeFromSuperview()
    self.blurView(isHidden: true)
    self.view.setNeedsDisplay()
  }
}

extension HomeViewController: GoMapViewDelegate {

  func didTapMarker(_ mapView: GMSMapView, didTap marker: GMSMarker) {
    let tappedPosition = marker.position
    let tappedLatitude = tappedPosition.latitude

    let filteredBike = goBikes.filter { $0.location?.latitude == tappedLatitude }

    if filteredBike.count > 0 {
      updatePullUpView(present: true, bike: filteredBike[0])
    }
    let tappedBikeLocation = CLLocation(latitude: (filteredBike[0].location?.latitude)!, longitude: (filteredBike[0].location?.longitude)!)

    drawPath(destinationLocation: tappedBikeLocation)

    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goMarkerClick, properties: ["Marker Latitude": tappedPosition.latitude , "Marker Longitude": tappedPosition.longitude])
  }

  func didTapOnMap(_ mapView: GMSMapView) {
    if !goPullUpView.isHidden {
      updatePullUpView(present: false)
    }
  }

  func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
    refreshButton.isHidden = false
  }

  func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
    refreshButton.isHidden = true
  }

  func drawPath(destinationLocation: CLLocation) {
    guard let lat = self.goMapView?.myLocation?.coordinate.latitude,
      let lng = self.goMapView?.myLocation?.coordinate.longitude else { return }

    let origin = "\(lat),\(lng)"
    let destination = "\(destinationLocation.coordinate.latitude),\(destinationLocation.coordinate.longitude)"

    let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking"


    Alamofire.request(url as URLConvertible, encoding: JSONEncoding.default).responseJSON { response in
      switch response.result {
      case .success:
        if let value = response.result.value {
          let parsedJson = JSON(value)
          print("postRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) VALUE: \(parsedJson) \n")
          let routes = parsedJson["routes"].arrayValue
          for route in routes {
            let routeOverviewPolyline = route["overview_polyline"].dictionary
            let points = routeOverviewPolyline?["points"]?.stringValue
            let path = GMSPath.init(fromEncodedPath: points!)
            self.polyline.path = path
            self.polyline.strokeColor = UIColor.appThemeColor
            self.polyline.strokeWidth = 5.0
            self.polyline.map = self.goMapView
          }
        }
      case .failure(let error):
        print("postRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) ERROR: \(error)")
      }
      }.resume()
  }
}


extension HomeViewController: UserProfileDelegate {
  func didTapSignOut() {
    self.userProfileView?.removeFromSuperview()
    self.blurView(isHidden: true)
    self.view.setNeedsDisplay()
  }

  func didTapMapButton() {
    self.didTapMap()
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


extension GMSMapView {
  func mapStyle(withFilename name: String, andType type: String) {
    do {
      if let styleURL = Bundle.main.url(forResource: name, withExtension: type) {
        self.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        NSLog("Unable to find style.json")
      }
    } catch {
      NSLog("One or more of the map styles failed to load. \(error)")
    }
  }
}
