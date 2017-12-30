//
//  ExtraChargesViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 20/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

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

  fileprivate var extaCharge: Int!
  fileprivate var safeLocations: [GOSafeLocation]!
  fileprivate var booking: GOBooking!

  fileprivate var tableViewHandler: NearLocationsTableViewDelegateDataSource?

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, extraCharge: Int, safeLocations: [GOSafeLocation], booking: GOBooking) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.extaCharge = extraCharge
    self.safeLocations = safeLocations
    self.booking = booking
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    setUpViews()
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
    title += "\(extaCharge)" + Defaults.extraString
    payButton.setTitle(title, for: .normal)
  }

  fileprivate func loadTableView() {
    tableViewHandler = NearLocationsTableViewDelegateDataSource.init(locations: self.safeLocations)
    tableViewHandler?.delegate = self
    tableViewHandler?.setUpForTableView(nearestLocationsTableView)
    nearestLocationsTableView.reloadData()
  }


  @IBAction func didTapCancelButton(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func didTapPayButton(_ sender: Any) {
    WheelstreetAPI.dropBike(forBookingID: self.booking.bookingId, forceDrop: true, showEndKm: true, completion: { (reading, extraCharge, safeLocations, trip, status) in
      guard status == .SUCCESS else {
        WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(status))
        return
      }

      if let trip = trip {
        let endTripViewController = EndTripViewController(nibName: "EndTripViewController", bundle: nil, trip: trip)
        self.present(endTripViewController, animated: true, completion: {
          return
        })
      }
    })
  }
}
