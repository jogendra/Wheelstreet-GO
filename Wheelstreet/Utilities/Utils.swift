//
//  Utils.swift
//  Campus Buddy
//
//  Created by Kush Taneja on 01/12/16.
//  Copyright © 2016 Kush Taneja. All rights reserved.
//

import Foundation
import UIKit

class Utils {
    
    
    func returnWhiteSpaceCharacters() -> CharacterSet {
        return CharacterSet.whitespaces
    }
    

    func alertView(_ vc: UIViewController, title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.removeFromSuperview()
    }
    func alertViewWithButton(_ vc: UIViewController, title: String, message: String,buttonText: String,action:((UIAlertAction) -> Swift.Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: .default, handler: action))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        myActivityIndicator.stopAnimating()
        myActivityIndicator.removeFromSuperview()
    }
    
  func addEffectsInTextField(_ textField: HoshiTextField, placeholder:String, borderActiveColor: UIColor = UIColor.appThemeColor, borderInactiveColor: UIColor = UIColor.appThemeColor, fontSize: CGFloat = 17) {
        textField.placeholderColor = borderInactiveColor//UIColor.white
        textField.placeholder = placeholder
        textField.borderActiveColor = borderActiveColor//UIColor.loginSignUpTextFieldHighlightColor
        textField.borderInactiveColor = borderInactiveColor//UIColor.white
        textField.placeholderFontScale = CGFloat(0.85)
        textField.font = UIFont(name: "AvenirNext-Regular", size: fontSize)
        textField.textColor = UIColor.black//UIColor.white
        textField.tintColor = borderActiveColor//UIColor.loginSignUpTextFieldHighlightColor
        

        textField.isSecureTextEntry = placeholder.lowercased().contains("password")
        textField.returnKeyType = placeholder.lowercased().contains("password") ? .send : .done
        textField.keyboardType = placeholder.lowercased().contains("enrol") || placeholder.lowercased().contains("phone") ? .numberPad : .default
        }
    
    
    func makeAnimatedTextFieldFillTheContainerView(_ textField: HoshiTextField, containerView: UIView) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: textField, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0).isActive = true
    }
    
    func showErrorOnAnimatedTextField(_ textField: HoshiTextField, errorMessageLabel: UILabel ,errorMessage: String, errorExists: inout Bool) {
        textField.borderInactiveColor = UIColor.iosRed
        errorMessageLabel.text = errorMessage
        errorExists = true
    }

    
    
    func checkNSUserDefault(_ key:String)->String {
        if(UserDefaults.standard.object(forKey: key) != nil) {
            return (UserDefaults.standard.object(forKey: key) as! String)
        }
        return ""
    }
    
    
    // give delay in execution
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // check for TextField validations
    
    func isValidEmail(_ testStr:String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let range = testStr.range(of: emailRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isValidPassword(_ testStr:String) -> Bool{
        let passwordRegEx = "^.{6,}$"
        let range = testStr.range(of: passwordRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    func isValidPhoneNumber(_ testStr:String) -> Bool{
        let phoneNumberRegEx = "^.{10,}$"
        let range = testStr.range(of: phoneNumberRegEx, options:.regularExpression)
        let result = range != nil ? true : false
        return result
    }

    func getDeviceWidth() -> CGFloat {
        return UIScreen.main.bounds.width
    }
    
    func getDeviceHeight() -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    
}
