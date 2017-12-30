

//
//  FareDetailsViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 23/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

fileprivate enum Defaults {
  static let applicableString: String = "• "
  static let additionalNote: String = "Note: Additional"
  static let extraChargesNote: String = "will be charged for not parking at any of the safe locations mentioned below."
}

class FareDetailsViewController: UIViewController {

  @IBOutlet weak var labelBaseFare: UILabel!
  @IBOutlet weak var labelPerKm: UILabel!
  @IBOutlet weak var labelPerMinute: UILabel!
  @IBOutlet weak var labelPerMinuteBuffer: UILabel!
  @IBOutlet weak var labelExtraCharges: UILabel!

  @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var safeLocationTableView: UITableView!

  fileprivate var bike: GoBike!
  fileprivate var bikeLocations: [GOSafeLocation] = []
  fileprivate var tableViewHandler: NearLocationsTableViewDelegateDataSource?


  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, bike: GoBike) {
    self.bike = bike

    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupInitialViews()
    getFareDetails()
  }

  func setupInitialViews() {
    labelBaseFare.text = ""
    labelPerKm.text = ""
    labelPerMinute.text = ""

    labelPerMinuteBuffer(isHidden: true)
    labelExtraCharges(isHidden: true)
  }

  func getFareDetails() {
    WheelstreetAPI.getFareDetails(forBike: self.bike) { (fareDetails, minuteOffer, minuteOfferMessage, extraCharges, safelocations, status) in
      switch status {
      case .SUCCESS:
        if let fareDetails = fareDetails {
          self.configureViewsWith(fareDetails: fareDetails, minuteOffer: minuteOffer, minuteOfferMessage: minuteOfferMessage, extraCharges: extraCharges)

          if let safelocations = safelocations {
            self.bikeLocations = safelocations
            self.tableViewHandler = NearLocationsTableViewDelegateDataSource(locations: self.bikeLocations.sorted { (a, b) -> Bool in
              return Int(b.distance!) > Int(a.distance!)
            })

            self.tableViewHandler?.delegate = self
            self.tableViewHandler?.setUpForTableView(self.safeLocationTableView)
            self.tableViewHeightConstraint.constant = CGFloat(80*self.bikeLocations.count + 50)
            self.safeLocationTableView.reloadData()
          }
        }

      default:
        WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(status))
      }
    }
  }

  func configureViewsWith(fareDetails: GoFareDetails, minuteOffer: Int?, minuteOfferMessage: String?, extraCharges: Int?) {
    labelBaseFare.text = "₹ \(fareDetails.baseRate)"
    labelPerKm.text = "₹ \(fareDetails.kmRate)"
    labelPerMinute.text = "₹ \(fareDetails.minRate)"

    labelPerMinuteBuffer(isHidden: minuteOffer == nil)

    if let minuteOffer = minuteOffer, let minuteOfferMessage = minuteOfferMessage {
      labelPerMinuteBuffer(minOfferMsg: minuteOfferMessage)
    }

    labelExtraCharges(isHidden: minuteOffer == nil)

    if let extraCharges = extraCharges {
      labelExtraCharges(extraCharges: "₹ \(extraCharges)")
    }
  }

  func labelPerMinuteBuffer(minOfferMsg: String) {
    labelPerMinuteBuffer.text = "• ".appending(minOfferMsg)
  }

  func labelPerMinuteBuffer(isHidden: Bool) {
    labelPerMinuteBuffer.isHidden = isHidden
  }

  func labelExtraCharges(extraCharges: String) {
    labelExtraCharges.text = Defaults.additionalNote.appending(" ") + extraCharges.appending(" ") + Defaults.extraChargesNote
  }

  func labelExtraCharges(isHidden: Bool) {
    labelExtraCharges.isHidden = isHidden
  }

  @IBAction func didTapCancel(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}

