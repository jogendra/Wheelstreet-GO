//
//  StatusViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 28/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

protocol StatusViewControllerDelegate: class {
  func didTapNotificationView(userStatus: UserStatus)
}

class StatusViewController: UIViewController {

  var rootVC: UIViewController!
  var statusLabelHeight: CGFloat = 0
  lazy var notificationView = UIView()
  lazy var textLabel = UILabel()
  weak var delegate: StatusViewControllerDelegate?

  var userStatus: UserStatus! {
    didSet {
      isVisible =  userStatus != .none
    }
  }

  var isVisible: Bool = true

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, userStatus: UserStatus, rootVC: UIViewController) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.userStatus = userStatus
    self.rootVC = rootVC
    self.isVisible =  userStatus != .none
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpInputViews()
  }

  func setUpInputViews() {
    setNotificationViewFrame()

    notificationView.backgroundColor = UIColor.iosRed
    view.addSubview(notificationView)

    addLabelWithAnimation()
    addTapGuestureToNotificationView()

    setRootVCFrame()
    view.addSubview(rootVC.view)

    configureUserStatus()
  }

  @objc func didTapNotificationView() {
    delegate?.didTapNotificationView(userStatus: self.userStatus)

    switch userStatus {
    case .notLoggedIn:
      let splashScreen = UIStoryboard.splashNavigationScreen()
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.navigationController = UINavigationController(rootViewController: splashScreen)
      UIApplication.topViewController()!.present(appDelegate.navigationController!, animated: true, completion: nil)
    case .underVerification, .verified:
      break
    case .notUploaded, .rejected:
      WheelstreetViews.statusBarToDefault()
      let kycUploadScreen = GOKYCUploadViewController(nibName: "GOKYCUploadViewController", bundle: nil, type: .front)
      let navigationVC = UINavigationController(rootViewController: kycUploadScreen)
      UIApplication.navigationController().present(navigationVC, animated: true, completion: nil)
      break
    default:
      return
    }
  }

  func addTapGuestureToNotificationView() {
    let tapGuesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapNotificationView))
    notificationView.addGestureRecognizer(tapGuesture)
  }

  func addLabelWithAnimation() {
    textLabel = UILabel(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height , width: UIApplication.shared.statusBarFrame.width, height: 32))
    textLabel.text = ""
    textLabel.textColor = UIColor.white
    textLabel.textAlignment = .center
    textLabel.backgroundColor = UIColor.clear
    textLabel.font = UIFont.systemFont(ofSize: 15)
    notificationView.addSubview(textLabel)
    addTextLabelAnimations()
  }

  func updateNotificationView(color: UIColor, text: String) {
    notificationView.backgroundColor = color
    textLabel.text = text
  }

  func addTextLabelAnimations() {
    textLabel.addPulseAnimation(from: 0.4, to: 1, duration: 0.8, key: "opacity")
  }

  func removeTextLabelAnimations() {
    textLabel.layer.removeAllAnimations()
  }

  func updateTopBar() {
    setNotificationViewFrame()
    setRootVCFrame()
    setStatusBar()
  }

  func setStatusBar() {
    if isVisible {
      WheelstreetViews.statusBarTo(color: UIColor.clear, style: .lightContent)
      return
    }
    else {
      WheelstreetViews.statusBarTo(color: UIColor.clear, style: .default)
    }
  }

  func setNotificationViewFrame() {
    var notificationFrame = UIApplication.shared.statusBarFrame
    if isVisible {
      notificationFrame.size.height += 32
      addTextLabelAnimations()
    }
    else {
      notificationFrame.size.height -= 32
      removeTextLabelAnimations()
    }
    notificationView.frame = notificationFrame
  }

  func setRootVCFrame() {
    if isVisible {
      var frame = self.view.frame
      frame.size.height -= (UIApplication.shared.statusBarFrame.height + 32)
      frame.origin.y += (UIApplication.shared.statusBarFrame.height + 32)
      rootVC.view.frame = frame
    }
    else {
      rootVC.view.frame = self.view.frame
    }
  }
  

  func configureUserStatus() {
    switch userStatus {
    case .notLoggedIn:
      isVisible = true
      updateTopBar()
      updateNotificationView(color: UIColor.iosRed, text: "Please Tap here to login")
    case .verified:
      isVisible = true
      updateTopBar()
      updateNotificationView(color: UIColor(red:0.1, green:0.81, blue:0.57, alpha:1), text: "Driving License Status: Verified")
      Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false, block: { (timer) in
        self.isVisible = false
        self.updateTopBar()
        timer.invalidate()
      })
    case .rejected:
      isVisible = true
      updateTopBar()
      updateNotificationView(color: UIColor(red:0.81, green:0.1, blue:0.1, alpha:1), text: "Driving license status: Rejected \n Tap here to Upload Driving License")
    case .underVerification:
      isVisible = true
      updateTopBar()
      updateNotificationView(color: UIColor(red:0.96, green:0.65, blue:0.14, alpha:1), text: "Driving License Status: Under Verification")
    case .notUploaded:
      isVisible = true
      updateTopBar()
      updateNotificationView(color: UIColor.black, text: "Tap here to Upload Driving License")
    default:
      isVisible = false
      updateTopBar()
    }
  }

  func topViewController() -> UIViewController? {
    return self.rootVC
  }

}

