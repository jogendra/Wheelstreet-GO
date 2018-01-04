
//
//  EndTripViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 22/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import GoogleMaps
import FacebookShare
import Mixpanel

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
    configureWithTrip()

    self.navigationItem.setRightBarButton(UIBarButtonItem(title: "Help", style: .plain, target: self, action: #selector(help)), animated: true)
    Mixpanel.mainInstance().time(event: GoMixPanelEvents.goPayment)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    view.endEditing(true)
    configurePaymentSatusView()

    self.navigationController?.isNavigationBarHidden = false
    self.navigationController?.navigationBar.barTintColor = UIColor.white
    self.navigationController?.navigationBar.backgroundColor = UIColor.white
    self.navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.black,
      NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .bold)
    ]
    self.navigationController?.navigationBar.barStyle = .default
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()

    if #available(iOS 11.0, *) {
      self.navigationController?.navigationBar.prefersLargeTitles = true
    } else {
      // Fallback on earlier versions
    }
    self.title = "Trip Details"
  }

  func configureWithTrip() {
    bikeNameLabel.text = trip.bike.bikeModelName
    bikeNumberLabel.text = trip.bike.regNo
    priceLabel.text = "₹" + trip.totalAmount!
    let distance = trip.endKm! - trip.startKm!
    distanceLabel.text =  String(describing: distance) + " km"

    let interval = trip.endDateTime! - trip.startDateTime!
    durationLabel.text =  WheelstreetCommon.prettyStringFromTimeInterval(interval: interval)

    transactionStatusLabel.text = ""

    switch trip.paymentStatus {
    case .faliure:
      payButton.isEnabled = true
      paymentStatus = .failure
    case .success:
      paymentStatus = .success
    case .initiate:
      paymentStatus = .standard
      payButton.isEnabled = true
    }

    configurePaymentSatusView()
  }

  //MARK: Payments
  func setupPaytmMerchant() {
    merchantConfig = PGMerchantConfiguration.default()
    merchantConfig.checksumGenerationURL = "https://www.wheelstreet.com/payment/generate-checksum"
    merchantConfig.checksumValidationURL = "https://www.wheelstreet.com/payment/verify-checksum"
    merchantConfig.merchantID = "Bashar14780895321034"
    merchantConfig.website = "Basharweb"
    merchantConfig.industryID = "Retail110"
    merchantConfig.channelID = "WEB"
  }

  func presentPayment() {
    odrDict["ORDER_ID"] = "\(self.trip.orderId)"
    odrDict["MID"] = "Bashar14780895321034"
    odrDict["CUST_ID"] = "\(UserDefaults.standard.value(forKey: GoKeys.userId) as! Int)"
    odrDict["CHANNEL_ID"] = "WEB"
    odrDict["INDUSTRY_TYPE_ID"] = "Retail110"
    odrDict["WEBSITE"] = "Basharweb"
    odrDict["TXN_AMOUNT"] = self.trip.totalAmount!
    odrDict["THEME"] = "merchant"
    odrDict["REQUEST_TYPE"] = "DEFAULT"
    odrDict["EMAIL"] = "\(Utils().checkNSUserDefault(GoKeys.email))"
    odrDict["MOBILE_NO"] = "\(Utils().checkNSUserDefault(GoKeys.mobileNumber))"
    odrDict["CALLBACK_URL"] = "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=\(self.trip.orderId)"

    WheelstreetAPI.getChecksumHash(oderData: odrDict) {(hash, status) in
      if status == .SUCCESS {
        if let hash = hash {
          self.odrDict["CHECKSUMHASH"] = hash
          let order: PGOrder = PGOrder(params: self.odrDict)
          self.transactionController = PGTransactionViewController(transactionFor: order)
          self.transactionController.serverType = eServerTypeProduction
          self.transactionController.merchant = self.merchantConfig
          self.transactionController.loggingEnabled = true
          self.transactionController.delegate = self

          let navVC = UINavigationController(rootViewController: (self.transactionController)!)
          self.transactionController!.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.attemptToDismissPayment)), animated: true)
          navVC.navigationBar.tintColor = UIColor.appThemeColor
          UIApplication.topViewController()?.present(navVC, animated: true, completion: nil)
        }
      }
      else {
        WheelstreetViews.somethingWentWrongAlertView()
      }
    }
  }

  @objc func attemptToDismissPayment() {
    WheelstreetViews.basicAlertView(title: "Alert", message: "Are you sure you want to cancel Transaction", handler: { (alert) in
      self.transactionController!.navigationController!.dismiss(animated: true, completion: {
        self.verifyPayment()
      })
    }, cancelHandler: nil)
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
      tableViewHeightConstraint.constant = CGFloat((rent.count + 1)*40 + 60)
    }
    else {
      tableViewHeightConstraint.constant = 0
    }
    paymentStatusView(isHidden: true)
    payView(isHidden: true)

    scrollViewTapGuestureRecognizer.addTarget(self, action: #selector(endEditing(_:)))
    scrollView.showsVerticalScrollIndicator = false
  }

  @objc func endEditing(_ sender: Any) {
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

    if let tripDiscount = trip.withoutDiscount?.toInt(), trip.totalAmount?.toInt() == 0, tripDiscount > 0 {
      payButton.setTitle("Your ride is on us, Book Another Ride", for: .normal)
      shareButton.setTitle("Share with friends to get their first ride free!", for: .normal)
    }
    else {
      payButton.setTitle(paymentStatus == .failure ? Defaults.payString + " " + Defaults.againString : Defaults.payString, for: .normal)
      shareButton.setTitle("Share your ride to get 50% off", for: .normal)
    }
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
          Mixpanel.mainInstance().track(event: GoMixPanelEvents.goPayment, properties: ["Amount": trip.totalAmount ?? "", "Payment ID": trip.orderId])
          self.trip = trip
          self.configureWithTrip()
          if let amount = self.trip.totalAmount!.toDouble() {
            Mixpanel.mainInstance().people.trackCharge(amount: amount)
          }
        }
        else {
          Mixpanel.mainInstance().track(event: GoMixPanelEvents.goRetryPayment, properties: ["Amount": self.trip.totalAmount ?? "", "Order ID": self.trip.orderId])
          self.paymentStatus = .failure
          self.configurePaymentSatusView()
        }
      })
    }
  }

  @IBAction func didTapShareButton(_ sender: Any) {
    Mixpanel.mainInstance().time(event: GoMixPanelEvents.goPaymentFBShare)
    let url = URL(string: "https://www.wheelstreet.com/")!
    let myContent = LinkShareContent(url: url)
    do {
    try ShareDialog<LinkShareContent>.show(from: self, content: myContent, completion: { (result) in
      Mixpanel.mainInstance().track(event: GoMixPanelEvents.goPaymentFBShare, properties: ["Amount": self.trip.totalAmount ?? ""])

      WheelstreetAPI.sharedOnFacebook(bookingId: "\(self.trip.bookingId)", postId: Int(Date().timeIntervalSince1970)) { (trip, errorMessage, status) in
      if status == .SUCCESS {
        self.trip = trip
        self.configureWithTrip()
        self.shareButton.setTitle("50% Discount Applied", for: .normal)
        self.shareButton.isEnabled = false
      }
      else {
        WheelstreetViews.alertView(title: errorMessage ?? "Something Went Wrong", message:" ")
        self.shareButton.setTitle("Share your ride to get 50% off", for: .normal)
        self.shareButton.isEnabled = true
      }
      }
    })
    }
    catch {
      WheelstreetViews.somethingWentWrongAlertView()
    }
  }

  @IBAction func didTapPayButton(_ sender: Any) {
    if let tripDiscount = trip.withoutDiscount?.toInt(), trip.totalAmount?.toInt() == 0, tripDiscount > 0 {
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.checkLoginAndSetRoot()
      }
      else {
        self.payButton.isEnabled = true

        WheelstreetViews.somethingWentWrongAlertView()
      }
    }
    else {
    WheelstreetAPI.getBookingDetails(forBookingID: self.trip.bookingId, completion: { (trip, status) in
      if let trip = trip {
        self.trip = trip
        self.presentPayment()
      }
      else {
        self.payButton.isEnabled = true
        WheelstreetViews.somethingWentWrongAlertView()
      }

    })
    }
  }
  
  @IBAction func didTapGoToMaps(_ sender: Any) {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
      appDelegate.checkLoginAndSetRoot()
    }
  }

  @objc func help() {
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
    guard let rent = self.trip.rent else {
      return 0
    }

    return self.trip.bookedOn == nil ? rent.count : rent.count + 1
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return Defaults.fareDetailsString
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: FareDetailsTableViewCell = tableView.dequeReusableCell(forIndexPath: indexPath)

    if let bookeOn = self.trip.bookedOn, indexPath.row == 0 {
      let rent = GORent(type: .bookedOn, rent: bookeOn, rate: 0, total: 0)
       cell.configure(rent: rent)
    }
    else if let rent = self.trip.rent?[indexPath.row - 1] {
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
