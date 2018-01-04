//
//  WheelstreetViews.swift
//  Appetizer
//
//  Created by Kush Taneja on 22/06/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import AVFoundation

class WheelstreetViews {
  static func alertView(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
      let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
      okAction.setValue(UIColor.goThemeColor, forKey: "titleTextColor")
      alert.addAction(okAction)
      UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
  }

  static func bluredAlertView(title: String, message: String, action: UIAlertAction? = nil) {
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
//        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        guard let topViewController = UIApplication.topViewController() else {
           return
        }
//      visualEffectView.frame = topViewController.view.frame
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let OKAction = UIAlertAction(title: "Dismiss", style: .default, handler: { action in
//            visualEffectView.removeFromSuperview()
      })
      alertController.addAction(OKAction)

    if let action = action {
      alertController.addAction(action)
    }
//    topViewController.view.addSubview(visualEffectView)
    topViewController.present(alertController, animated: true, completion: nil)
    }


  static func basicAlertView(title: String, message: String, actionButtonTitle: String? = "Confirm", actionStyle: UIAlertActionStyle? = .default, extraActions: [UIAlertAction]? = nil, handler: @escaping(UIAlertAction)->Void, cancelHandler: ((UIAlertAction)->Void)?, isCancelDarker: Bool = false) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

    let lighterColor = UIColor.appThemeColor
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: cancelHandler)
    cancelAction.setValue(isCancelDarker ? UIColor.appThemeColor : lighterColor, forKey: "titleTextColor")
    alert.addAction(cancelAction)

    let action = UIAlertAction(title: actionButtonTitle, style: actionStyle ?? .default, handler: handler)
    action.setValue(isCancelDarker ? lighterColor : UIColor.appThemeColor, forKey: "titleTextColor")
    alert.addAction(action)

    if let extraActions = extraActions {
      for extraAction in extraActions {
        extraAction.setValue(UIColor.appThemeColor, forKey: "titleTextColor")
        alert.addAction(extraAction)
      }
    }

    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
  }

  static func noInternetConnectionAlertView() {
    let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
      if let url = URL(string:"App-Prefs:root=MOBILE_DATA_SETTINGS_ID") {
        if UIApplication.shared.canOpenURL(url) {
          if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
          } else {
            UIApplication.shared.openURL(url)
          }
        }
      }
    }

     WheelstreetViews.bluredAlertView(title: "No Internet Connection", message: "Please connect to Internet", action: openAction)

    ActivityIndicator.shared.hideProgressView()
  }

  static func somethingWentWrongAlertView() {
    alertView(title: "Something Went Wrong", message: "Please Try Again Later")
  }

  static func requestCameraAcess(completion: @escaping((Bool)->Void)) {
    if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
      //already authorized
    } else {
      AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
        if !granted {
            WheelstreetViews.showCamerDisabledPopUp()
        }
      })

    }
  }

  static func showCamerDisabledPopUp() {
    let alertController = UIAlertController(title: "Camera Access",
                                            message: "In order to book go ride we need your camera permissions",
                                            preferredStyle: .alert)

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    cancelAction.setValue(UIColor.appThemeColor, forKey: "titleTextColor")
    alertController.addAction(cancelAction)

    let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
      if let url = URL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }
    openAction.setValue(UIColor.appThemeColor, forKey: "titleTextColor")
    alertController.addAction(openAction)

    UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
  }

  static func networkActivityIndicator(visible: Bool, showActivityIndicator: Bool? = true) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = visible

    if let showActivityIndicator = showActivityIndicator, showActivityIndicator {
      if visible {
        ActivityIndicator.shared.showProgressView()
      }
      else {
        ActivityIndicator.shared.hideProgressView()
      }
    }
  }

  static func statusBarToDefault() {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    UIApplication.shared.statusBarStyle = .default
    appDelegate.statusBar?.backgroundColor = UIColor.clear
  }

  static func statusBarTo(color: UIColor, style: UIStatusBarStyle) {
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    UIApplication.shared.statusBarStyle = style
    appDelegate.statusBar?.backgroundColor = color
  }

  static func makeToast(message: String, cancelHandler: (()->())? = { }) {
    if let topViewController = UIApplication.topViewController() {
      topViewController.view.makeToast(message: message)
    }
    else {
      cancelHandler!()
    }
  }
}
