//
//  SignUpViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 15/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Alamofire

enum UserAuthStatus {
    case preSignin
    case signin
    case signup
}

class UserViewController: UIViewController {
    
    @IBOutlet weak var userVCTitle: UILabel!

    @IBOutlet weak var userEmailTextField: HoshiTextField!
    
    @IBOutlet weak var userNameTextField: HoshiTextField!
    
    @IBOutlet weak var userMobileNumberTextField: HoshiTextField!
    
    @IBOutlet weak var userPasswordTextField: HoshiTextField!
    
    @IBOutlet var scrollView: UIScrollView!

    @IBOutlet weak var userActionButton: UIButton!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var emailActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var nameFieldTopOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var nameFieldHeightOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var mobileFieldTopOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var mobileFieldHeightOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var forgotPasswordHeightOutlet: NSLayoutConstraint!
    
    @IBOutlet weak var forgotPasswordTopOutlet: NSLayoutConstraint!
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!

    @IBOutlet var scrollViewTapGuestureRecognizer: UITapGestureRecognizer!
    var otpResend: Bool?
    
    var authStatus: UserAuthStatus = .preSignin
    
    var userMobileNumber: String?
    
    var userEmail: String?
    
    var mobileNumberShouldChange: Bool = true
    
    var userEnteredOTP: String?
    
    var middleLayer: UIView?
    
    var enterOTPView = Bundle.main.loadNibNamed("EnterOTPView", owner: self, options: nil)?.first as? EnterOTPView
    
    var OTPTimer: Timer?
    var seconds: Int = 0
    var activeField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      UISetups()
      userStatusUISetups(userStatus: authStatus)
      scrollViewTapGuestureRecognizer.addTarget(self, action: #selector(endEditing(_:)))
      scrollView.showsVerticalScrollIndicator = false
      userEmailTextField.delegate = self
      userNameTextField.delegate = self
      userMobileNumberTextField.delegate = self
      userPasswordTextField.delegate = self
    }

    @objc func endEditing(_ sender: Any) {
      view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        startNotification()
        userEmailTextField.becomeFirstResponder()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        userEmailTextField.resignFirstResponder()
        enterOTPView?.OTPEnterTextField.resignFirstResponder()
    }


  func startNotification() {
    NotificationCenter.default.addObserver(self, selector: #selector(UserViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(UserViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }

  func stopNotification() {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }

  @objc func keyboardWillShow(_ aNotification: Notification) {
    var info: [AnyHashable: Any] = aNotification.userInfo!
    let kbSize: CGSize = (((info[UIKeyboardFrameEndUserInfoKey])! as AnyObject).cgRectValue.size)


    if (activeField != nil) {
      let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
      scrollView.contentInset = contentInsets
      scrollView.scrollIndicatorInsets = contentInsets
      var aRect: CGRect = self.view.frame
      aRect.size.height -= kbSize.height
      if !aRect.contains(activeField!.frame.origin) {
        self.bottomConstraint.constant = kbSize.height - activeField!.frame.height
        let bottomOffset = CGPoint(x: CGFloat(0), y: CGFloat(kbSize.height))
        self.scrollView.setContentOffset(bottomOffset, animated: true)
        self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
      }
    }

    guard let enterOTPView = enterOTPView else {
      return
    }

      UIView.animate(withDuration: 0.3, animations: {
        enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height - enterOTPView.frame.height - kbSize.height, width: self.view.frame.width, height: 200.0)
      })
  }

  @objc func keyboardWillBeHidden(_ aNotification: Notification) {
    let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    self.scrollView.contentInset = contentInsets
    self.scrollView.scrollIndicatorInsets = contentInsets
    scrollView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)

    guard let enterOTPView = enterOTPView else {
      return
    }
    UIView.animate(withDuration: 0.3, animations: {
      enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height - enterOTPView.frame.height, width: self.view.frame.width, height: 200.0)
    })
  }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(true)

      self.navigationController?.isNavigationBarHidden = false
      self.navigationController?.navigationBar.barTintColor = UIColor.white
      self.navigationController?.navigationBar.backgroundColor = UIColor.white
      self.navigationController?.navigationBar.tintColor = UIColor.appThemeColor
      self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
      self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)

        stopNotification()
    }


    
    @IBAction func userActionButtonTapped(_ sender: Any) {

        view.endEditing(true)
        guard let userEmail = userEmailTextField.text, let userName =  userNameTextField.text, let userMobileNumber = userMobileNumberTextField.text, let userPassword = userPasswordTextField.text else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        
        if !userEmail.isValidEmail() {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Please enter valid email address")
            return
        }
        
        switch authStatus {
        case .preSignin:
            return
        case .signin:
            signinAction(userEmail: userEmail, userPassword: userPassword)
        case .signup:
            signupAction(userEmail: userEmail, userName: userName, userMobileNumber: userMobileNumber, userPassword: userPassword)
        }
    }
    
    func addMiddleLayer() {
        middleLayer = UIView()
        guard let middleLayer = middleLayer else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        middleLayer.layer.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        middleLayer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(middleLayer)
    }
    
    func UISetups() {
        
        userMobileNumberTextField.text = userMobileNumber ?? ""
        userActionButton.layer.cornerRadius = 0.5 * userActionButton.frame.height
        
        userMobileNumberTextField.keyboardType = .numberPad
        
//        // Signup with fb button setup
//        let fbIconImage = UIImage(named: GoImages.fbSigninSignupIcon)
//        fbAuthButton.setImage(fbIconImage, for: .normal)
//        fbAuthButton.leftAlignedTextAndImage(spacing: 26.0)
//
//        // Hide Fb authentication Button till we add the fb ios sdk to our app
//        // TODO: Implement fb ios sdk
//        fbAuthButton.isHidden = true
//        fbAuthButton.isUserInteractionEnabled = false
//        fbAuthButton.isEnabled = false

            if !(mobileNumberShouldChange) {
                userMobileNumberTextField.text = userMobileNumber
                userMobileNumberTextField.isUserInteractionEnabled = false
                userMobileNumberTextField.isEnabled = false
            }
        
    }
    
    func userStatusUISetups(userStatus: UserAuthStatus) {
        switch userStatus {
        case .preSignin:
            initialUISetups()
        case .signin:
            signinStatusUISetup()
        case .signup:
            signupStatusUISetup()
        }
    }
    
    func presentEnterOTPView() {
        self.view.endEditing(true)
        guard let enterOTPView = enterOTPView else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        addMiddleLayer()
        enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 200.0)
        enterOTPView.editNumberForOTPButton.setTitle("Dismiss", for: .normal)
        enterOTPView.enterOTPDelegate = self
        enterOTPView.signinOtherAccountButton.addTarget(self, action: #selector(signinOtherAccountButtonTapped(_:)), for: .touchUpInside)
        enterOTPView.editNumberForOTPButton.addTarget(self, action: #selector(editNumberButtonTapped(_:)), for: .touchUpInside)
        enterOTPView.layer.opacity = 0.4
        UIView.animate(withDuration: 1, animations: {
            enterOTPView.frame = CGRect(x: 0, y: self.view.frame.height - enterOTPView.frame.height, width: self.view.frame.width, height: 200.0)
            self.middleLayer?.addSubview(enterOTPView)
            self.runTimer()
            enterOTPView.layer.opacity = 1.0
        }, completion: { (bool) in
          enterOTPView.OTPEnterTextField.becomeFirstResponder()
        })
    }
    
    @objc func signinOtherAccountButtonTapped(_ sender: Any) {
        
    }
    
    @objc func editNumberButtonTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.goBackToSignup()
        })
    }
    
    func userAunthentications() {
        
        userEmail = userEmailTextField.text
        
        guard let userEmail = userEmail else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        
        let paramas: Parameters = ["source": 3, "email": userEmail]
        
        if userEmail.isValidEmail() {
            emailActivityIndicator.isHidden = false
            emailActivityIndicator.startAnimating()
            WheelstreetAPI.verifyEnteredOTP(params: paramas, completion: { parsedJSON, statusCode, error, code in
                if let data = parsedJSON, let serverResponseCode = data["status"].int {
                    guard let statusCode = statusCode else {
                        return
                    }
                    self.emailAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode)
                }
                else {
                  self.view.showToast(message: "Error. Please try again")
              }
            })
        } else {
            self.view.makeToast(message: "Please enter valid email to proceed")
        }
    }
    
    func emailAuthAPIHandler(serverStatusCode: Int, serverResponseCode: Int) {
        if serverStatusCode == 200 && serverResponseCode == 3 {
            self.view.showToast(message: "Email is already registred. Please signin to proceed.")
            authStatus = .signin
            userStatusUISetups(userStatus: authStatus)
        } else if serverStatusCode == 422, serverResponseCode == -4 {
            authStatus = .signup
            userStatusUISetups(userStatus: authStatus)
        } else {
            authStatus = .preSignin
            userStatusUISetups(userStatus: authStatus)
        }
    }

  func hitSinghUpAPI(enteredOTP: String) {
    guard let userEmail = userEmailTextField.text, let userName =  userNameTextField.text, let userMobileNumber = userMobileNumberTextField.text, let userPassword = userPasswordTextField.text else {
      return
    }

    let signupParameteres: Parameters = ["source": 3, "name": userName, "email": userEmail, "mobile": userMobileNumber, "password": userPassword, "otpResend": false, "otp": enteredOTP]

    WheelstreetAPI.userSignup(params: signupParameteres, completion: { parsedJSON, statusCode, error, code in
      if error != nil {
        self.view.showToast(message: "Error. Please try again")
      } else {
        if let data = parsedJSON, let serverResponseCode = data["status"].int {
          guard let statusCode = statusCode else {
            return
          }
          let userData = data["data"]
          let responseError = data["error"].string
          switch code {
          case .SUCCESS:
            self.signupAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, resposeError: responseError, goUser: GoUser(data: userData))
          default:
            self.signupAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, resposeError: responseError, goUser: nil)
          }
        }
      }
    })
  }
    
    func signupAction(userEmail: String, userName: String, userMobileNumber: String, userPassword: String) {
        
        if userName.isEmpty || userEmail.isEmpty || userMobileNumber.isEmpty || userPassword.isEmpty {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "All fields are required!")
            return
        }
        
        if userMobileNumber.count < 10 || !userMobileNumber.isNumeric {
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Please enter 10 digit valid mobile number")
            return
        }
        
            if mobileNumberShouldChange {
            let preSignupParamas: Parameters = ["source": 3, "name": userName, "email": userEmail, "mobile": userMobileNumber, "password": userPassword, "otpResend": false]
            WheelstreetAPI.userPreSignup(params: preSignupParamas, completion: { parsedJSON, statusCode, error in
                if error != nil {
                    self.view.makeToast(message: "Error. Please try again")
                } else {
                    self.presentEnterOTPView()
                }
            })
            
        } else {
            guard let enteredOTP: String = userEnteredOTP else {
                return
            }

            hitSinghUpAPI(enteredOTP: enteredOTP)
        }
    }
    
    func signinAction(userEmail: String, userPassword: String) {
        let params: Parameters = ["source": 3, "param": userEmail, "password": userPassword]
        WheelstreetAPI.userSignin(params: params, completion: { parsedJSON, statusCode, error, code in
            if error != nil {
                self.view.makeToast(message: "Error. Please try again")
            } else {
                if let data = parsedJSON, let serverResponseCode = data["status"].int {
                    guard let statusCode = statusCode else {
                        return
                    }
                    let responseError = data["error"].string
                    let userData = data[GoKeys.data]
                    switch code {
                    case .SUCCESS:
                        self.signinAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, resposeError: responseError, goUser: GoUser(data: userData))
                    default:
                        self.signinAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, resposeError: responseError, goUser: nil)
                    }
                }
            }
        })
    }
    
    func signinAuthAPIHandler(serverStatusCode: Int, serverResponseCode: Int, resposeError: String?, goUser: GoUser?) {
        if serverStatusCode == 200 && serverResponseCode == 1 {
            guard let goUser = goUser else {
                return
            }
            GoUserDefaultsService.setUserData(for: goUser)
            GoUserDefaultsService.setProfileData(for: goUser)
            gotoGoHome()
        } else if serverStatusCode == 422 {
            WheelstreetViews.bluredAlertView(title: "Alert", message: resposeError ?? "Error. try again")
        }
    }
    
    func signupAuthAPIHandler(serverStatusCode: Int, serverResponseCode: Int, resposeError: String?, goUser: GoUser?) {
      if serverStatusCode == 200 && (serverResponseCode == 1 || serverResponseCode == 2) {
            guard let goUser = goUser else {
              WheelstreetViews.somethingWentWrongAlertView()
                return
            }
            GoUserDefaultsService.setUserData(for: goUser)
            GoUserDefaultsService.setProfileData(for: goUser)
            gotoGoHome()
        } else if serverStatusCode == 422 {
            WheelstreetViews.bluredAlertView(title: "Alert", message: resposeError ?? "Error. try again")
        }
    }
    
    func preSignupAuthAPIHandler(serverStatusCode: Int, serverResponseCode: Int, resposeError: String?) {
        if serverStatusCode == 200 && serverResponseCode == 2 {
            // Succes: send user to map screen
            gotoGoHome()
        } else if serverStatusCode == 422 && serverResponseCode == -3 {
            // Invalid OTP
            WheelstreetViews.bluredAlertView(title: "Alert", message: "Invalid OTP")
        } else if serverStatusCode == 422 && serverResponseCode == -5 {
            hitSinghUpAPI(enteredOTP: self.userEnteredOTP!)
        } else {
            WheelstreetViews.bluredAlertView(title: "Alert", message: resposeError ?? "Error. try again")
        }
    }
    
    func gotoGoHome() {
      UserDefaults.standard.set(true, forKey: GoKeys.isUserLoggedIn)
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      appDelegate.checkLoginAndSetRoot()
      self.updateUserProfileInformation()
    }
    
    func goBackToSignup() {
        OTPTimer?.invalidate()
        enterOTPView?.OTPEnterTextField.text = nil
        enterOTPView?.OTPEnterTextField.resignFirstResponder()
        middleLayer?.removeFromSuperview()
        enterOTPView?.removeFromSuperview()
    }

    fileprivate func runTimer() {
        seconds = 0
        
        enterOTPView?.resendTimeCounterLabel.isHidden = false
        enterOTPView?.resendOTPButton.isHidden = true
        enterOTPView?.resendOTPButton.isUserInteractionEnabled = false
        
        OTPTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func updateUserProfileInformation() {
        WheelstreetAPI.getUserProfileDetail(completion: { parsedJSON, statusCode, error in
            switch statusCode {
            default:
                WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(statusCode))
            }
        })
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
        }else{
            OTPTimer?.invalidate()
        }
    }
    
    // UI setups according to user status
    func initialUISetups() {
        nameFieldHeightOutlet.constant = 0.0
        nameFieldTopOutlet.constant = 0.0
        mobileFieldHeightOutlet.constant = 0.0
        mobileFieldTopOutlet.constant = 0.0
        forgotPasswordTopOutlet.constant = 0.0
        forgotPasswordHeightOutlet.constant = 0.0
        nameFieldTopOutlet.priority = UILayoutPriority(rawValue: 999)
        nameFieldHeightOutlet.priority = UILayoutPriority(rawValue: 999)
        mobileFieldTopOutlet.priority = UILayoutPriority(rawValue: 999)
        mobileFieldHeightOutlet.priority = UILayoutPriority(rawValue: 999)
        forgotPasswordTopOutlet.priority = UILayoutPriority(rawValue: 999)
        forgotPasswordHeightOutlet.priority = UILayoutPriority(rawValue: 999)
        userNameTextField.isHidden = true
        userMobileNumberTextField.isHidden = true
        userPasswordTextField.isHidden = true
        userActionButton.isHidden = true
        forgotPasswordButton.isHidden = true
        emailActivityIndicator.isHidden = true
        userVCTitle.text = "Sign in"
    }
    
    func signinStatusUISetup() {
        nameFieldHeightOutlet.constant = 0.0
        nameFieldTopOutlet.constant = 0.0
        mobileFieldHeightOutlet.constant = 0.0
        mobileFieldTopOutlet.constant = 0.0
        forgotPasswordHeightOutlet.constant = forgotPasswordButton.frame.height
        forgotPasswordTopOutlet.constant = 29.0
        forgotPasswordTopOutlet.priority = UILayoutPriority(rawValue: 500)
        forgotPasswordHeightOutlet.priority = UILayoutPriority(rawValue: 500)
        nameFieldTopOutlet.priority = UILayoutPriority(rawValue: 999)
        nameFieldHeightOutlet.priority = UILayoutPriority(rawValue: 999)
        mobileFieldTopOutlet.priority = UILayoutPriority(rawValue: 999)
        mobileFieldHeightOutlet.priority = UILayoutPriority(rawValue: 999)
        forgotPasswordTopOutlet.isActive = true
        forgotPasswordHeightOutlet.isActive = true
        userNameTextField.isHidden = true
        userMobileNumberTextField.isHidden = true
        userPasswordTextField.isHidden = false
        userActionButton.isHidden = false
        forgotPasswordButton.isHidden = false
        userVCTitle.text = "Sign in"
        emailActivityIndicator.isHidden = true
        userActionButton.setTitle("Sign in", for: .normal)
    }
    
    func signupStatusUISetup() {
        forgotPasswordTopOutlet.constant = 0.0
        forgotPasswordHeightOutlet.constant = 0.0
//        userNameTextField.setNeedsDisplay()
//        userMobileNumberTextField.setNeedsDisplay()
        nameFieldHeightOutlet.constant = 65.0
        mobileFieldHeightOutlet.constant = 65.0
        nameFieldTopOutlet.constant = 18.0
        mobileFieldTopOutlet.constant = 18.0
        nameFieldTopOutlet.priority = UILayoutPriority(rawValue: 500)
        nameFieldHeightOutlet.priority = UILayoutPriority(rawValue: 500)
        mobileFieldTopOutlet.priority = UILayoutPriority(rawValue: 500)
        mobileFieldHeightOutlet.priority = UILayoutPriority(rawValue: 500)
        forgotPasswordTopOutlet.priority = UILayoutPriority(rawValue: 999)
        forgotPasswordHeightOutlet.priority = UILayoutPriority(rawValue: 999)
        nameFieldTopOutlet.isActive = true
        nameFieldHeightOutlet.isActive = true
        mobileFieldTopOutlet.isActive = true
        mobileFieldHeightOutlet.isActive = true
//        forgotPasswordTopOutlet.isActive = true
//        forgotPasswordHeightOutlet.isActive = true
        forgotPasswordButton.isHidden = true
        userNameTextField.isHidden = false
        userNameTextField.setNeedsDisplay()
        userMobileNumberTextField.isHidden = false
        userMobileNumberTextField.setNeedsDisplay()
        userNameTextField.setNeedsDisplay()
        userPasswordTextField.isHidden = false
        userActionButton.isHidden = false
        userVCTitle.text = "Sign up"
        emailActivityIndicator.isHidden = true
        emailActivityIndicator.stopAnimating()
        userActionButton.setTitle("Sign up", for: .normal)
    }

  
}

extension UserViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userEmailTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        userMobileNumberTextField.resignFirstResponder()
        userPasswordTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.accessibilityIdentifier == "email" {
            userAunthentications()
        }

      self.view.endEditing(true)
      activeField = nil
    }
    
}

extension UserViewController: EnterOTPDelegate {
    func didTapResendOTPButton() {
        guard let userEmail = userEmailTextField.text, let userName =  userNameTextField.text, let userMobileNumber = userMobileNumberTextField.text, let userPassword = userPasswordTextField.text else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        let preSignupParamas: Parameters = ["source": 3, "name": userName, "email": userEmail, "mobile": userMobileNumber, "password": userPassword, "otpResend": true]
        WheelstreetAPI.userPreSignup(params: preSignupParamas, completion: { parsedJSON, statusCode, error in
            if error != nil {
                self.view.makeToast(message: "Error. Please try again")
            } else {
                self.presentEnterOTPView()
            }
        })
    }

    func didTextFieldValueChange(value: String) {
        guard let mobileNumber = userMobileNumberTextField.text else {
           view.endEditing(true)
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        if value.count > 3 {
          view.endEditing(true)
          self.userEnteredOTP = value
          let params: Parameters = ["source": 3, "mobile": mobileNumber, "otp": value]
            WheelstreetAPI.verifyEnteredOTP(params: params, completion: { parsedJSON, statusCode, error, code in
                if error != nil {
                    self.view.showToast(message: "Error. Please try again")
                } else {
                    if let data = parsedJSON, let serverResponseCode = data["status"].int {
                        guard let statusCode = statusCode else {
                          self.view.showToast(message: "Error. Please try again")
                            return
                        }
                        let responseError = data["error"].string
                        self.preSignupAuthAPIHandler(serverStatusCode: statusCode, serverResponseCode: serverResponseCode, resposeError: responseError)
                    }
                }
            })
        }
    }
}
