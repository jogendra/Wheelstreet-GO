
//
//  EndTripViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 22/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import GoogleMaps

fileprivate enum Defaults {
  static let cornerRadius: CGFloat = 4.0
  static let borderWidth: CGFloat = 1.0
  static let fareDetailsString: String = "FARE DETAILS"
  static let transactionString : String = "TRANSACTION"
  static let successfulString : String = "SUCCESSFUL"
  static let unSuccessfulString : String = "UNSUCCESSFUL"
  static let payString: String = "Pay"
  static let againString: String = "Again"
}

enum GOTripPaymentStatus {
  case success
  case failure
  case standard
}

class EndTripViewController: UIViewController {

  @IBOutlet var bikeNameLabel: UILabel!
  @IBOutlet var bikeNumberLabel: UILabel!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var distanceLabel: UILabel!
  @IBOutlet var durationLabel: UILabel!
  @IBOutlet var transactionStatusLabel: UILabel!
  
  @IBOutlet var scrollView: UIScrollView!
  @IBOutlet var paymentStatusView: UIView!

  @IBOutlet var transactionView: UIView!
  @IBOutlet var payView: UIView!

  @IBOutlet var shareButton: UIButton!
  @IBOutlet var payButton: UIButton!
  @IBOutlet var goToMaps: UIButton!
  
  @IBOutlet var fareDetailsTableView: UITableView!

  @IBOutlet var paymentStatusViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var goMapsButtonTopConstraint: NSLayoutConstraint!
  @IBOutlet var goMapsButtonHeightConstraint: NSLayoutConstraint!
  @IBOutlet var paymentStatusViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet var payViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var shareButtonBottomConstraint: NSLayoutConstraint!
  @IBOutlet var payViewTopConstraint: NSLayoutConstraint!
  @IBOutlet var paymentStatusLabelViewHeight: NSLayoutConstraint!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!

  @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var scrollViewTapGuestureRecognizer: UITapGestureRecognizer!

  var merchantConfig: PGMerchantConfiguration!
  var odrDict: [String : Any] = [:]
  var transactionController: PGTransactionViewController!
  var trip: GOTrip!

  var paymentStatus: GOTripPaymentStatus = .standard

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, trip: GOTrip) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.trip = trip
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) for EndTripViewController has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupInitialViews()
    setupPaytmMerchant()
    configureTrip()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    view.endEditing(true)
    configurePaymentSatusView()
    UIApplication.makeNavigationBarTransparent(statusBarStyle: .default)
  }


  override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)

    UIApplication.makeNavigationBarTransparent(statusBarStyle: .default)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    view.endEditing(true)
  }

  func configureTrip() {
    bikeNameLabel.text = trip.bike.bikeModelName
    bikeNumberLabel.text = trip.bike.regNo
    priceLabel.text = "₹" + trip.totalAmount!
    let distance = trip.endKm! - trip.startKm!
    distanceLabel.text =  String(describing: distance) + " km"

    let interval = trip.endDateTime! - trip.startDateTime!
    durationLabel.text =  WheelstreetCommon.prettyStringFromTimeInterval(interval: TimeInterval(interval), date: trip.startDate!)

    transactionStatusLabel.text = ""
    if trip.paymentDetails?.isEmpty == true || trip.paymentDetails == nil {
      paymentStatus = .standard
    }
    else {
      paymentStatus = .failure
    }

    configurePaymentSatusView()
  }

  //MARK: Payments
  func setupPaytmMerchant() {
    merchantConfig = PGMerchantConfiguration.default()
    merchantConfig.checksumGenerationURL = "https://www.wheelstreet.org/payment/generate-checksum"
    merchantConfig.checksumValidationURL = "https://www.wheelstreet.org/payment/verify-checksum"

    merchantConfig.merchantID = "Bashar31727478105952"
    merchantConfig.website = "Basharweb"
    merchantConfig.industryID = "Retail"
    merchantConfig.channelID = "WEB"
  }

  func presentPayment() {
    odrDict["ORDER_ID"] = "\(self.trip.orderId)"
    odrDict["MID"] = "Bashar31727478105952"
    odrDict["CUST_ID"] = "\(UserDefaults.standard.value(forKey: GoKeys.userId) as! Int)"
    odrDict["CHANNEL_ID"] = "WEB"
    odrDict["INDUSTRY_TYPE_ID"] = "Retail"
    odrDict["WEBSITE"] = "Basharweb"
    odrDict["TXN_AMOUNT"] = self.trip.totalAmount!
    odrDict["THEME"] = "merchant"
    odrDict["EMAIL"] = "\(Utils().checkNSUserDefault(GoKeys.email))"
    odrDict["MOBILE_NO"] = "\(Utils().checkNSUserDefault(GoKeys.mobileNumber))"
    odrDict["CALLBACK_URL"] = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=\(self.trip.orderId)"

    WheelstreetAPI.getChecksumHash(oderData: odrDict) {(hash, status) in
      if status == .SUCCESS {
        if let hash = hash {
          self.odrDict["CHECKSUMHASH"] = hash
          let order: PGOrder = PGOrder(params: self.odrDict)
          self.transactionController = PGTransactionViewController(transactionFor: order)
          self.transactionController.serverType = eServerTypeStaging
          self.transactionController.merchant = self.merchantConfig
          self.transactionController.loggingEnabled = true
          self.transactionController.delegate = self
          
          UIApplication.topViewController()?.present((self.transactionController)!, animated: true, completion: nil)
        }
      }
      else {
        WheelstreetViews.somethingWentWrongAlertView()
      }
    }
  }

  func setupInitialViews() {
    bikeNameLabel.text = ""
    bikeNumberLabel.text = ""
    priceLabel.text = ""
    distanceLabel.text = ""
    durationLabel.text = ""
    transactionStatusLabel.text = ""

    shareButton.layer.cornerRadius = Defaults.cornerRadius
    shareButton.layer.masksToBounds = true
    shareButton.layer.borderColor = UIColor.facebook.withAlphaComponent(0.4).cgColor
    shareButton.layer.borderWidth = Defaults.borderWidth

    payButton.layer.cornerRadius = Defaults.cornerRadius
    payButton.layer.masksToBounds = true

    goToMaps.layer.cornerRadius = Defaults.cornerRadius
    goToMaps.layer.masksToBounds = true
    goToMaps.layer.borderColor = UIColor.appThemeColor.withAlphaComponent(0.4).cgColor
    goToMaps.layer.borderWidth = Defaults.borderWidth

    fareDetailsTableView.isScrollEnabled = false
    fareDetailsTableView.delegate = self
    fareDetailsTableView.dataSource = self
    fareDetailsTableView.tableFooterView = UIView(frame: CGRect.zero)
    fareDetailsTableView.backgroundColor = UIColor.clear
    fareDetailsTableView.showsVerticalScrollIndicator = false
    fareDetailsTableView.register(FareDetailsTableViewCell.self)
    if let rent = self.trip.rent {
      tableViewHeightConstraint.constant = CGFloat(rent.count*40 + 60)
    }
    else {
      tableViewHeightConstraint.constant = 0
    }
    paymentStatusView(isHidden: true)
    payView(isHidden: true)

    scrollViewTapGuestureRecognizer.addTarget(self, action: #selector(endEditing))
    scrollView.showsVerticalScrollIndicator = false
  }

  @objc func endEditing() {
    view.endEditing(true)
  }

  func configurePaymentSatusView() {
    switch paymentStatus {
    case .standard:
      paymentStatusView(isHidden: true)
      payView(isHidden: false)
      payButton.setTitle(Defaults.payString, for: .normal)
    case .success:
      paymentStatusView(isHidden: false)
      goMapsButton(isHidden: false)
      payView(isHidden: true)
    case .failure:
      paymentStatusView(isHidden: false, goToMaps: false)
      goMapsButton(isHidden: true)
      payButton.setTitle(Defaults.payString + " " + Defaults.againString, for: .normal)
      payView(isHidden: false)
    }
    configureTransactionLabel(paymentStatus: self.paymentStatus)
  }

  func paymentStatusView(isHidden: Bool, goToMaps: Bool = true) {
    paymentStatusView.isHidden = isHidden

    if goToMaps {
      paymentStatusViewHeightConstraint.constant = isHidden ? 0 : 106
    }
    else {
      paymentStatusViewHeightConstraint.constant = isHidden ? 0 : 49
    }

    paymentStatusViewHeightConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
    paymentStatusLabelViewHeight.constant = isHidden ? 0 : 38

    paymentStatusLabelViewHeight.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
    paymentStatusViewBottomConstraint.constant = isHidden ? 0 : 26
    paymentStatusViewBottomConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
  }

  func goMapsButton(isHidden: Bool) {
    goToMaps.isHidden = isHidden

    goMapsButtonHeightConstraint.constant = isHidden ? 0 : 50
    goMapsButtonHeightConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))

    goMapsButtonTopConstraint.constant = isHidden ? 0 : 18
    goMapsButtonTopConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
  }

  func payView(isHidden: Bool) {
    payView.isHidden = isHidden
    payViewHeightConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
    payViewHeightConstraint.constant = isHidden ? 0 : 104

    payViewTopConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
    payViewTopConstraint.constant = isHidden ? 0 : 32

    shareButtonBottomConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isHidden ? 999 : 500))
    shareButtonBottomConstraint.constant = isHidden ? 0 : 16

  }


  func configureTransactionLabel(paymentStatus: GOTripPaymentStatus) {
    var text = Defaults.transactionString
    switch paymentStatus {
    case .success:
      text += " " + Defaults.successfulString
      transactionStatusLabel.textColor = UIColor.appThemeColor
      transactionView.backgroundColor = UIColor.appThemeColor.withAlphaComponent(0.12)
    case .failure:
      text += " " + Defaults.unSuccessfulString
      transactionStatusLabel.textColor = UIColor.iosRed
      transactionView.backgroundColor = UIColor.iosRed.withAlphaComponent(0.12)
    default:
      return
    }
    transactionStatusLabel.text = text

  }

  fileprivate func verifyPayment() {
    WheelstreetAPI.verifyPayment(orderId: "\(self.trip.orderId)") { (trip, status) in
      self.transactionController!.dismiss(animated: true, completion: {
        if let trip = trip {
          self.trip = trip
        }
        else {
          self.paymentStatus = .failure
        }

        self.configureTrip()
      })
    }
  }


  @IBAction func didTapShareButton(_ sender: Any) {
    WheelstreetAPI.sharedOnFacebook(bookingId: "\(self.trip.bookingId)", postId: "\(Date().timeIntervalSince1970)") { (trip, errorMessage, status) in
      if status == .SUCCESS {
        self.trip = trip
        self.configureTrip()
      }
      else {
        WheelstreetViews.alertView(title: errorMessage ?? "Something Went Wrong", message:" ")
      }
    }
  }

  @IBAction func didTapPayButton(_ sender: Any) {
    presentPayment()
  }
  
  @IBAction func didTapGoToMaps(_ sender: Any) {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.checkLoginAndSetRoot()
    }
  }

  @IBAction func didTapHelpButton(_ sender: Any) {
    WheelstreetCommon.help()
  }
  
  /*
  func startNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(EndTripViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(EndTripViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }

  func stopNotification() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }

  @objc func keyboardWillShow(_ aNotification: Notification) {
    var info: [AnyHashable: Any] = aNotification.userInfo!
    let kbSize: CGSize = (((info[UIKeyboardFrameEndUserInfoKey])! as AnyObject).cgRectValue.size)
    let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
    scrollView.contentInset = contentInsets
    scrollView.scrollIndicatorInsets = contentInsets
    var aRect: CGRect = self.view.frame
    aRect.size.height -= kbSize.height

    guard let activeField = couponCodeTextField, !aRect.contains(activeField.frame.origin) else {
      return
    }
    self.bottomConstraint.constant = kbSize.height - activeField.frame.height
    let bottomOffset = CGPoint(x: CGFloat(0), y: CGFloat(kbSize.height))
    self.scrollView.setContentOffset(bottomOffset, animated: true)
    self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
  }

  @objc func keyboardWillBeHidden(_ aNotification: Notification) {
    let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
    self.bottomConstraint.constant = 16.0
  }
  */
}

extension EndTripViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 40.0
  }
}

extension EndTripViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.trip.rent?.count ?? 0
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Defaults.fareDetailsString
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: FareDetailsTableViewCell = tableView.dequeReusableCell(forIndexPath: indexPath)

    if let rent = self.trip.rent?[indexPath.row] {
      cell.configure(rent: rent)
    }

    return cell
  }
}

extension EndTripViewController: PGTransactionDelegate {
  func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
    self.verifyPayment()
  }

  func didCancelTrasaction(_ controller: PGTransactionViewController!) {
    self.verifyPayment()
  }

  func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
   self.verifyPayment()
  }

}
