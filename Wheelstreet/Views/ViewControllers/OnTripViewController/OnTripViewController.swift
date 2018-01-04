//
//  OnTripViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import SafariServices
import Mixpanel

fileprivate enum Defaults {
  static let cornerRadius: CGFloat = 4.0
  static let borderWidth: CGFloat = 1.0
}

class OnTripViewController: UIViewController {

  @IBOutlet var bikeNameLabel: UILabel!
  @IBOutlet var bikeNumberLabel: UILabel!
  @IBOutlet var timerLabel: UILabel!
  @IBOutlet var minuteChargeLabel: UILabel!
  @IBOutlet var minuteConditionLabel: UILabel!
  @IBOutlet var OTPLabel: UILabel!

  @IBOutlet var nearLocationsTableView: UITableView!

  @IBOutlet var endTripButton: UIButton!

  @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!

  var refuelView = Bundle.main.loadNibNamed("RefuelView", owner: self, options: nil)?.first as! RefuelView
  lazy var middleLayer = UIView()

  fileprivate var tableViewHandler: NearLocationsTableViewDelegateDataSource?

  fileprivate var booking: GOBooking!
  fileprivate weak var tripTimmer: Timer?
  fileprivate var tripTime: Int = 0 {
    didSet {
       timerLabel.text = WheelstreetCommon.timerStringFromTimeInterval(interval: tripTime)
       scheduleTimer()
    }
  }

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, booking: GOBooking? = nil) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    if let booking = booking {
      self.booking = booking
    }
    else {
      updateTrip()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpInitialViews()

    if let booking = self.booking {
      self.updateViews(withBooking: booking)
    }
    
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goTripStart, properties: ["Booking ID": booking.bookingId])
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.navigationBar.barTintColor = UIColor.white
    self.navigationController?.navigationBar.backgroundColor = UIColor.white
    self.navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.black,
      NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .bold)
    ]
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
    self.navigationController?.navigationBar.barStyle = .default

    if #available(iOS 11.0, *) {
      self.navigationController?.navigationBar.prefersLargeTitles = true
    } else {

    }
    self.title = "On Trip"
  }

  fileprivate func setUpInitialViews() {
    endTripButton.layer.cornerRadius = Defaults.cornerRadius
    endTripButton.layer.masksToBounds = true
    endTripButton.layer.borderWidth = Defaults.borderWidth
    endTripButton.layer.borderColor = UIColor.appThemeColor.cgColor

    timerLabel.text = ""
    minuteChargeLabel.text = "₹1/min"
    setMinuteCondition(hidden: true)
  }

  fileprivate func setMinuteCondition(hidden: Bool) {
    minuteChargeLabel.isHidden = hidden
    minuteConditionLabel.isHidden = hidden
  }

  fileprivate func updateTrip() {
    WheelstreetAPI.homePageData { (booking, trip, bikes, kycStatus, status) in
      if let booking = booking, status == .SUCCESS {
        self.booking = booking
        self.updateViews(withBooking: booking)
        return
      }

      WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(status))
    }
  }

  func updateViews(withBooking booking: GOBooking) {
    bikeNameLabel.text = booking.bike.bikeModelName
    bikeNumberLabel.text = booking.bike.regNo

    OTPLabel.text = " \(booking.pin!)"
    
    tableViewHandler = NearLocationsTableViewDelegateDataSource(locations: booking.safeLocations.sorted { (a, b) -> Bool in
      return Int(b.distance!) > Int(a.distance!)
    })

    tableViewHeightConstraint.constant = CGFloat(80*booking.safeLocations.count + 50)
    tableViewHandler?.delegate = self
    tableViewHandler?.setUpForTableView(nearLocationsTableView)
    nearLocationsTableView.reloadData()

    if let startTime = booking.startDateTime {
      setTimerWithStartTime(startTime: startTime)
    }
    else {
      stopTimer()
      timerLabel.text = ""
    }
  }

  func setTimerWithStartTime(startTime: Int) {
    let diff = Int(Date().addingTimeInterval(TimeInterval(19800)).timeIntervalSince1970) - startTime
    tripTime = diff
  }

  func scheduleTimer() {
    if tripTimmer != nil {
      stopTimer()
    }

    tripTimmer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
  }

  @objc private func updateTimer(){
    tripTime += 1

    if tripTime > 1800 {
      setMinuteCondition(hidden: false)
    }
  }

  func stopTimer() {
    tripTimmer?.invalidate()
    tripTimmer = nil
  }

  func addMiddleLayer() {
    middleLayer.layer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
    middleLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    view.addSubview(middleLayer)
    let gestureRecognzier = UITapGestureRecognizer(target: self, action: #selector(dismissRefuelView))
    middleLayer.addGestureRecognizer(gestureRecognzier)
  }

  func presentRefuelView() {
    addMiddleLayer()
    refuelView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 337.5)
    refuelView.delegate = self
    refuelView.layer.opacity = 0.4
    UIView.animate(withDuration: 1, animations: {
      self.refuelView.frame = CGRect(x: 0, y: self.view.frame.height - self.refuelView.frame.height, width: self.view.frame.width, height: 337.5)
      self.middleLayer.addSubview(self.refuelView)
      self.refuelView.setOTPLabel()
      self.refuelView.layer.opacity = 1.0
    })
  }

  @objc func dismissRefuelView() {
    refuelView.removeFromSuperview()
    middleLayer.removeFromSuperview()
  }

  func attemptToEndTrip() {
    if let booking = self.booking {
      WheelstreetAPI.dropBike(forBookingID: booking.bookingId, completion: { (readings, extraCharge, safeLocations, trip, status) in
        guard status == .SUCCESS else {
          WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(status))
          return
        }

        if let reading = readings, extraCharge == nil {
          let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .end, bookingID: "\(self.booking.bookingId)", scannedBike: self.booking.bike, reading: reading)
          Mixpanel.mainInstance().track(event: GoMixPanelEvents.goEndTrip, properties: [
            "Booking ID": self.booking.bookingId, "In SafeLocation": true, "Entered KM": false])
          UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
          return
        }

        if let extraCharge = extraCharge, let safeLocation = safeLocations, let readings = readings {
          let extraChargesScreen = ExtraChargesViewController(nibName: "ExtraChargesViewController", bundle: nil, extraCharge: extraCharge, safeLocations: safeLocation, booking: self.booking!, reading: readings)
          WheelstreetViews.statusBarToDefault()
          Mixpanel.mainInstance().track(event: GoMixPanelEvents.goEndTrip, properties: [
            "Booking ID": self.booking.bookingId, "In SafeLocation": false, "Entered KM": false])
          UIApplication.navigationController().present(extraChargesScreen, animated: true, completion: {
            return
          })
        }

        if let trip = trip {
          Mixpanel.mainInstance().track(event: GoMixPanelEvents.goEndTrip, properties: [
            "Booking ID": self.booking.bookingId, "In SafeLocation": true, "Entered KM": true])
          let endTripViewController = EndTripViewController(nibName: "EndTripViewController", bundle: nil, trip: trip)
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          UIApplication.shared.statusBarStyle = .default
          UIView.transition(with: appDelegate.window!, duration: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
            appDelegate.setAppWitRootAs(vc: endTripViewController)
          }) { (canceled) in
            appDelegate.window!.makeKeyAndVisible()
          }
        }
      })
    }
    else {
      WheelstreetViews.alertView(title: "Something went wrong", message: "Try Again Later")
    }
  }
  


  @IBAction func didTapRefuelButton(_ sender: Any) {
      Mixpanel.mainInstance().track(event: GoMixPanelEvents.goRefuel, properties: ["Amount": self.booking.totalAmount ?? "", "Booking ID": self.booking.bookingId])
      presentRefuelView()
  }

  @IBAction func didTapDocumentsButton(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goDocuments, properties: ["Booking ID": self.booking.bookingId])
    if let documents = booking.documents, !documents.isEmpty {
      guard let topViewController = UIApplication.topViewController() else {
        WheelstreetViews.somethingWentWrongAlertView()
        return
      }

      if documents.count == 1 {
        let safariViewController = SFSafariViewController(url: documents.first!.value)
        topViewController.present(safariViewController, animated: true, completion: nil)
      }
      else {
        let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let alertVCSubView = alertVC.view.subviews.first?.subviews.first?.subviews.first {
          alertVCSubView.backgroundColor = UIColor.white
        }

        for (key, url) in documents {
          let action = UIAlertAction(title: key, style: .default, handler: { [weak self] (action) in
            let safariViewController = SFSafariViewController(url: url)
            topViewController.present(safariViewController, animated: true, completion: nil)
          })
          action.setValue(UIColor.appThemeColor, forKey: GoKeys.alertTitleKey)
          alertVC.addAction(action)
        }

        let cancelAlert = UIAlertAction(title: GoDefaults.cancelString, style: .cancel, handler: nil)
        cancelAlert.setValue(UIColor.appThemeColor, forKey: GoKeys.alertTitleKey)
        alertVC.addAction(cancelAlert)

        topViewController.present(alertVC, animated: true, completion: nil)
      }
    }
    
  }

  @IBAction func didSupportButton(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goCallOnTrip, properties: [
      "Booking ID": self.booking.bookingId])
    WheelstreetCommon.help()
  }

  @IBAction func didTapEndTripButton(_ sender: Any) {
    attemptToEndTrip()
  }

}

extension OnTripViewController: RefuelViewDelegate {
  func didTapDismiss() {
    dismissRefuelView()
  }

  func bikeOTP() -> String {
    return "\(self.booking.pin!)"
  }


}
