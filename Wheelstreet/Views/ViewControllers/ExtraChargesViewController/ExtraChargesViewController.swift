//
//  ExtraChargesViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Mixpanel

fileprivate enum Defaults {
  static let cornerRadius: CGFloat = 4.0
  static let borderWidth: CGFloat = 1.0
  static let payString: String = "Pay"
  static let extraString: String = "Extra"
}

class ExtraChargesViewController: UIViewController {

  @IBOutlet var nearestLocationsTableView: UITableView!

  @IBOutlet var cancelButton: UIButton!
  @IBOutlet var payButton: UIButton!

  @IBOutlet var heightConstraint: NSLayoutConstraint!
  fileprivate var extaCharge: Int!
  fileprivate var safeLocations: [GOSafeLocation]!
  fileprivate var booking: GOBooking!
  var reading: GoReading!

  fileprivate var tableViewHandler: NearLocationsTableViewDelegateDataSource?

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, extraCharge: Int, safeLocations: [GOSafeLocation], booking: GOBooking, reading: GoReading) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.extaCharge = extraCharge
    self.safeLocations = safeLocations
    self.booking = booking
    self.reading = reading
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpViews()

    Mixpanel.mainInstance().time(event: GoMixPanelEvents.goExtrachargesProceed)
  }

  fileprivate func setUpViews() {
    cancelButton.layer.cornerRadius = Defaults.cornerRadius
    cancelButton.layer.masksToBounds = true
    cancelButton.layer.borderWidth = Defaults.borderWidth
    cancelButton.layer.borderColor = UIColor.appThemeColor.cgColor

    payButton.layer.cornerRadius = Defaults.cornerRadius
    payButton.layer.masksToBounds = true

    setPayButtonTitle()
    loadTableView()
  }

  fileprivate func setPayButtonTitle() {
    var title = Defaults.payString
    title += " ₹\(extaCharge!) " + Defaults.extraString
    payButton.setTitle(title, for: .normal)
  }

  fileprivate func loadTableView() {
    tableViewHandler = NearLocationsTableViewDelegateDataSource.init(locations: self.safeLocations)
    heightConstraint.constant = CGFloat(80*(self.safeLocations.count) + 50)
    tableViewHandler?.delegate = self
    tableViewHandler?.setUpForTableView(nearestLocationsTableView)
    nearestLocationsTableView.reloadData()
  }


  @IBAction func didTapCancelButton(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goExtrachargesSkip)

    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func didTapPayButton(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goExtrachargesProceed)

    self.dismiss(animated: true, completion: {
      let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .end, bookingID: "\(self.booking.bookingId)", scannedBike: self.booking.bike, reading: self.reading, forceDrop: true)
      UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
    })
  }
}
