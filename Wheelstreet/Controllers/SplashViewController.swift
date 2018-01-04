//
//  SplashViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 14/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Alamofire

class SplashViewController: UIViewController {
    
    var keyboardHeight: CGFloat? = 0.0
    
    var mobileNumber: String?
    
    @IBOutlet weak var goLogoImageView: UIImageView!
    
    var sendOTPView = Bundle.main.loadNibNamed("SendOTPView", owner: self, options: nil)?.first as? SendOTPView
    
    var enterOTPView = Bundle.main.loadNibNamed("EnterOTPView", owner: self, options: nil)?.first as? EnterOTPView
    
    var enteredOTPNumberString: String?
    
    var mobileTextFieldShouldEnable: Bool?
    
    var userEnteredOTP: String?
    
    fileprivate var OTPTimer: Timer?
    fileprivate var seconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentSendOTPView()
        sendOTPView?.skipOTPButton.addTarget(self, action: #selector(skipButtonTapped(_:)), for: .touchUpInside)
        sendOTPView?.signinOtherAccountButton.addTarget(self, action: #selector(signinOtherAccountButtonTapped(_:)), for: .touchUpInside)
        sendOTPView?.sendOTPButton.addTarget(self, action: #selector(sendOTPAction(_:)), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        sendOTPView?.enterOTPMobileNumberTextField.becomeFirstResponder()
    }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    view.endEditing(true)
    sendOTPView?.enterOTPMobileNumberTextField.resignFirstResponder()
  }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        super.navigationController?.isNavigationBarHidden = true
        // Register Notification, To know When Key Board Appear.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        
        // Register Notification, To know When Key Board Hides.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        sendOTPView?.enterOTPMobileNumberTextField.resignFirstResponder()
        enterOTPView?.OTPEnterTextField.resignFirstResponder()
        view.endEditing(true)

        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
        }
        
        guard let sendOTPView = sendOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        guard let enterOTPView = enterOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        if keyboardHeight != nil {
            UIView.animate(withDuration: 0.3, animations: {
                sendOTPView.frame = CGRect(x: 0, y: self.view.frame.height - sendOTPView.frame.height - self.keyboardHeight!, width: self.view.frame.width, height: 223.0)
                self.goLogoImageView.frame = CGRect(x: (self.view.frame.width - self.goLogoImageView.frame.width)/2.0, y: 68.0, width: 110.0, height: 114.0)
                enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height - enterOTPView.frame.height - self.keyboardHeight!, width: self.view.frame.width, height: 200.0)
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let sendOTPView = sendOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        guard let enterOTPView = enterOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        UIView.animate(withDuration: 0.3, animations: {
            sendOTPView.frame = CGRect(x: 0, y: self.view.frame.height - sendOTPView.frame.height, width: self.view.frame.width, height: 223.0)
            self.goLogoImageView.frame = CGRect(x: (self.view.frame.width - self.goLogoImageView.frame.width)/2.0, y: (self.view.frame.height - self.goLogoImageView.frame.height)/2.0, width: 110.0, height: 114.0)
            
            enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height - enterOTPView.frame.height, width: self.view.frame.width, height: 200.0)
        })
    }
    
    @objc func skipButtonTapped(_ sender: Any) {
        view.endEditing(true)
        UserDefaults.standard.set(true, forKey: GoKeys.hasUserSkipped)
        UserDefaults.standard.set(false, forKey: GoKeys.isUserLoggedIn)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.checkLoginAndSetRoot()
    }
    
    @objc func signinOtherAccountButtonTapped(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        let storyboard = UIStoryboard(name: "User", bundle: nil)
        guard let signinViewController = storyboard.instantiateViewController(withIdentifier: "uservc") as? UserViewController else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        signinViewController.userMobileNumber = self.mobileNumber
        UIApplication.navigationController().pushViewController(signinViewController, animated: true)
    }
    
    @objc func sendOTPAction(_ sender: Any) {
        
        guard let sendOTPView = sendOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        
        enteredOTPNumberString = sendOTPView.enterOTPMobileNumberTextField.text
        
        guard let enteredOTPNumberString = enteredOTPNumberString else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }

        let params: Parameters = ["source": 3, "mobile": enteredOTPNumberString]
        
        if enteredOTPNumberString.isEmpty || enteredOTPNumberString.count < 10 || !enteredOTPNumberString.isNumeric || enteredOTPNumberString.count > 10 {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Please enter 10 digit valid mobile number")
            return
        }

      goLogoImageView.addPulseAnimation(from: 0.4, to: 1, duration: 0.8, key: "opacity")
        WheelstreetAPI.verifyEnteredOTP(params: params, completion: { parsedJSON, statusCode, error, code in
            if error != nil {
                self.view.showToast(message: "Error. Please try again")
            } else {
                if let data = parsedJSON, let serverResponseCode = data["status"].int {
                    guard let statusCode = statusCode else {
                        return
                    }
                    self.OTPAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, enteredOTP: nil, goUser: nil)
                }
            }
        })
        
    }
    
    func OTPAuthAPIHandler(serverStatusCode: Int, serverResponseCode: Int, enteredOTP: String?, goUser: GoUser?) {
        if serverStatusCode == 200 && serverResponseCode == 1 {
            self.view.makeToast(message: "OTP has been sent to your mobile number.")
            presentEnterOTPView()
            runTimer()
        } else if serverStatusCode == 422, serverResponseCode == -1 {
            self.view.makeToast(message: "OTP has been sent to your mobile number.")
            presentEnterOTPView()
            runTimer()
        } else if serverStatusCode == 422, serverResponseCode == -3 {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Invalid OTP")
        } else if serverStatusCode == 422, serverResponseCode == -6 {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Invalid Mobile Number")
        } else if serverStatusCode == 422, serverResponseCode == -5 {
            userEnteredOTP = enteredOTP
            UserDefaults.standard.set(enteredOTP, forKey: GoKeys.userOTP)
            self.goForSignup()
        } else if serverStatusCode == 200 && serverResponseCode == 2 {
            guard let goUser = goUser else {
                return
            }
            GoUserDefaultsService.setUserData(for: goUser)
            GoUserDefaultsService.setProfileData(for: goUser)
            gotoGoHome()
        } else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
    }
    
    func presentSendOTPView() {
        self.view.endEditing(true)
        enterOTPView?.removeFromSuperview()
        guard let sendOTPView = sendOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        sendOTPView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 223.0)
        sendOTPView.sendOTPDelegate = self
        sendOTPView.layer.opacity = 0.4
        UIView.animate(withDuration: 1, animations: {
            sendOTPView.frame = CGRect(x: 0, y: self.view.frame.height - sendOTPView.frame.height, width: self.view.frame.width, height: 223.0)
            self.goLogoImageView.frame = CGRect(x: (self.view.frame.width - self.goLogoImageView.frame.width)/2.0, y: (self.view.frame.height - self.goLogoImageView.frame.height)/2.0, width: 110.0, height: 114.0)
            self.view.addSubview(sendOTPView)
            sendOTPView.becomeFirstResponder()
            sendOTPView.layer.opacity = 1.0
        }, completion: { (bool) in
          sendOTPView.becomeFirstResponder()
        })
    }
    
    func presentEnterOTPView() {
        self.view.endEditing(true)
        sendOTPView?.removeFromSuperview()
        guard let enterOTPView = enterOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }

        enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200.0)
        
        enterOTPView.resendOTPButton.isHidden = true
        enterOTPView.resendOTPButton.isUserInteractionEnabled = false
        enterOTPView.resendTimeCounterLabel.isHidden = false
        
        enterOTPView.enterOTPDelegate = self
        enterOTPView.signinOtherAccountButton.addTarget(self, action: #selector(signinOtherAccountButtonTapped(_:)), for: .touchUpInside)
        enterOTPView.editNumberForOTPButton.addTarget(self, action: #selector(editNumberButtonTapped(_:)), for: .touchUpInside)
        // enterOTPView.sendOTPDelegate = self
        enterOTPView.layer.opacity = 0.4
        UIView.animate(withDuration: 1, animations: {
            enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height - enterOTPView.frame.height, width: self.view.frame.width, height: 200.0)
            self.goLogoImageView.frame = CGRect(x: (self.view.frame.width - self.goLogoImageView.frame.width)/2.0, y: (self.view.frame.height - self.goLogoImageView.frame.height)/2.0, width: 110.0, height: 114.0)
            self.view.addSubview(enterOTPView)
            enterOTPView.resendTimeCounterLabel.isHidden = true
            enterOTPView.layer.opacity = 1.0
        }, completion: { (bool) in
          enterOTPView.OTPEnterTextField.becomeFirstResponder()
        })
    }
    
    func goForSignup() {
        mobileTextFieldShouldEnable = false
        guard let signupViewController = UIStoryboard.userVC() as? UserViewController else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        signupViewController.userEnteredOTP = self.userEnteredOTP
        signupViewController.userMobileNumber = self.mobileNumber
        signupViewController.mobileNumberShouldChange = self.mobileTextFieldShouldEnable!
        signupViewController.authStatus = .signup
         //UIApplication.navigationController().pushViewController(signupViewController, animated: true)
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }
    
    func gotoGoHome() {
        UserDefaults.standard.set(true, forKey: GoKeys.isUserLoggedIn)
        self.updateUserProfileInformation()
      if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        appDelegate.checkLoginAndSetRoot()
      }
    }
    
    @objc func editNumberButtonTapped(_ sender: Any) {
        OTPTimer?.invalidate()
        enterOTPView?.OTPEnterTextField.text = nil
        presentSendOTPView()
    }
    
    fileprivate func runTimer() {
        seconds = 0
        
        enterOTPView?.resendTimeCounterLabel.isHidden = false
        enterOTPView?.resendOTPButton.isHidden = true
        enterOTPView?.resendOTPButton.isUserInteractionEnabled = false
        
        OTPTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func updateTimer(){
        if (seconds != 120){
            seconds += 1
            enterOTPView?.resendTimeCounterLabel.text = seconds <= 60 ? "Resend in 1:\(60 - seconds)" : "Resend in 0:\(120 - seconds)"
        } else if seconds == 120 {
            OTPTimer?.invalidate()
            guard let enterOTPView = enterOTPView else {
                return
            }
            enterOTPView.resendTimeCounterLabel.isHidden = true
            enterOTPView.resendOTPButton.isHidden = false
            enterOTPView.resendOTPButton.isUserInteractionEnabled = true
        }
        else{
            OTPTimer?.invalidate()
        }
    }
    
    func updateUserProfileInformation() {
      goLogoImageView.addPulseAnimation(from: 0.4, to: 1, duration: 0.8, key: "opacity")
        WheelstreetAPI.getUserProfileDetail(completion: { parsedJSON, statusCode, error in
            switch statusCode {
            default:
                WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(statusCode))
            }
        })
    }
}

extension SplashViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendOTPView?.enterOTPMobileNumberTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
}

extension SplashViewController: SendOTPDelegate {
    func getEnteredMobileNumber(_ mobileNumber: String) {
        self.mobileNumber = mobileNumber
    }
}

extension SplashViewController: EnterOTPDelegate {
    func didTapResendOTPButton() {
        guard let mobileNumber = sendOTPView?.enterOTPMobileNumberTextField.text else {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Please re-enter mobile number")
            return
        }
        let params: Parameters = ["source": 3, "mobile": mobileNumber]

      goLogoImageView.addPulseAnimation(from: 0.4, to: 1, duration: 0.8, key: "opacity")

        WheelstreetAPI.verifyEnteredOTP(params: params, completion: { parsedJSON, statusCode, error, code in
            if error != nil {
                self.view.showToast(message: "Error. Please try again")
            } else {
                if let data = parsedJSON, let serverResponseCode = data["status"].int {
                    guard let statusCode = statusCode else {
                        return
                    }
                    let userData = data["data"]
                    switch code {
                    case .SUCCESS:
                        self.OTPAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, enteredOTP: nil, goUser: GoUser(data: userData))
                    default:
                        self.OTPAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, enteredOTP: nil, goUser: nil)
                    }
                    
                }
            }
        })
    }
    
    func didTextFieldValueChange(value: String) {
        
        guard let mobileNumber = sendOTPView?.enterOTPMobileNumberTextField.text else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        let params: Parameters = ["source": 3, "mobile": mobileNumber, "otp": value]
        if value.count > 3 {
          goLogoImageView.addPulseAnimation(from: 0.4, to: 1, duration: 0.8, key: "opacity")

            WheelstreetAPI.verifyEnteredOTP(params: params, completion: { parsedJSON, statusCode, error, code in
                if error != nil {
                    self.view.showToast(message: "Error. Please try again")
                } else {
                    if let data = parsedJSON, let serverResponseCode = data["status"].int {
                        guard let statusCode = statusCode else {
                            return
                        }
                        let userData = data["data"]
                        switch code {
                        case .SUCCESS:
                            self.OTPAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, enteredOTP: nil, goUser: GoUser(data: userData))
                        default:
                            self.OTPAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, enteredOTP: value, goUser: nil)
                        }

                    }
                }
            })
        }
    }
}

