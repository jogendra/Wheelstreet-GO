//
//  WheelstreetViews.swift
//  Appetizer
//
//  Created by Kush Taneja on 22/06/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class WheelstreetViews {
    
  static func alertView(title: String, message: String) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
      let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
      okAction.setValue(UIColor.goThemeColor, forKey: "titleTextColor")
      alert.addAction(okAction)
      UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
  }

    static func bluredAlertView(title: String, message: String) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        guard let topViewController = UIApplication.topViewController() else {
           return
        }
        visualEffectView.frame = topViewController.view.frame
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            visualEffectView.removeFromSuperview()
        })
        alertController.addAction(OKAction)
        topViewController.view.addSubview(visualEffectView)
        topViewController.present(alertController, animated: true, completion: nil)
    }

  static func basicAlertView(title: String, message: String, actionButtonTitle: String? = "Confirm", actionStyle: UIAlertActionStyle? = .default, extraActions: [UIAlertAction]? = nil, handler: @escaping(UIAlertAction)->Void, cancelHandler: ((UIAlertAction)->Void)?, isCancelDarker: Bool = false) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)

    let lighterColor = UIColor.appThemeDark.withAlphaComponent(0.6)
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: cancelHandler)
    cancelAction.setValue(isCancelDarker ? UIColor.appThemeDark : lighterColor, forKey: "titleTextColor")
    alert.addAction(cancelAction)

    let action = UIAlertAction(title: actionButtonTitle, style: actionStyle ?? .default, handler: handler)
    action.setValue(isCancelDarker ? lighterColor : UIColor.appThemeDark, forKey: "titleTextColor")
    alert.addAction(action)

    if let extraActions = extraActions {
      for extraAction in extraActions {
        extraAction.setValue(UIColor.appThemeDark.withAlphaComponent(0.6), forKey: "titleTextColor")
        alert.addAction(extraAction)
      }
    }

    UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
  }

  static func noInternetConnectionAlertView() {
    ActivityIndicator.shared.hideProgressView()
    makeToast(message: "Oh no, Lost internet connection, Please retry After some time")
  }

  static func somethingWentWrongAlertView() {
    alertView(title: "Something Went Wrong", message: "Please Try Again Later")
  }

  static func networkActivityIndicator(visible: Bool) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = visible

    if visible {
       ActivityIndicator.shared.showProgressView()
    }
    else {
       ActivityIndicator.shared.hideProgressView()
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
