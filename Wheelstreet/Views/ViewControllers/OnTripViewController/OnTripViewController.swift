//
//  OnTripViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

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
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
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
    let diff = Int(Date().timeIntervalSince1970) - startTime
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
      WheelstreetAPI.dropBike(forBookingID: booking.bookingId, forceDrop: false, showEndKm: true, completion: { (reading, extraCharge, safeLocations, trip, status) in
        guard status == .SUCCESS else {
          WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(status))
          return
        }

        if let reading = reading {
          let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .end, bookingID: "\(self.booking.bookingId)", scannedBike: self.booking.bike, reading: reading)
          UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
          return
        }

        if let extraCharge = extraCharge, let safeLocations = safeLocations {
          let extraChargesScreen = ExtraChargesViewController(nibName: "ExtraChargesViewController", bundle: nil, extraCharge: extraCharge, safeLocations: safeLocations, booking: self.booking!)
          UIApplication.navigationController().present(extraChargesScreen, animated: true, completion: {
            return
          })
        }

        if let trip = trip {
        let endTripViewController = EndTripViewController(nibName: "EndTripViewController", bundle: nil, trip: trip)
        UIApplication.navigationController().present(endTripViewController, animated: true, completion: {
            return
          })
        }

      })

    }
    else {
      WheelstreetViews.alertView(title: "Something went wrong", message: "Try Again Later")
    }
  }
  


  @IBAction func didTapRefuelButton(_ sender: Any) {
      presentRefuelView()
  }

  @IBAction func didTapDocumentsButton(_ sender: Any) {

  }

  @IBAction func didSupportButton(_ sender: Any) {
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
