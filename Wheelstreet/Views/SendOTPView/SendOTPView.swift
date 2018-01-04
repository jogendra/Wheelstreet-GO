//
//  OTPHandlerView.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 14/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

protocol SendOTPDelegate: class {
    
    func getEnteredMobileNumber(_ mobileNumber: String)
}

class SendOTPView: UIView {
    
    @IBOutlet weak var enterOTPMobileNumberTextField: HoshiTextField!
    
    @IBOutlet weak var skipOTPButton: UIButton!
    
    @IBOutlet weak var sendOTPButton: UIButton!
    
    @IBOutlet weak var signinOtherAccountButton: UIButton!
    
    weak var sendOTPDelegate: SendOTPDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        signinOtherAccountButton.addTarget(self, action: #selector(signinOtherAccountTapped(_:)), for: .touchUpInside)
        
        sendOTPButton.addTarget(self, action: #selector(sendOTPTapped(_:)), for: .touchUpInside)
        // Set Number Pad type Keyboard to Text field
        enterOTPMobileNumberTextField.keyboardType = .numberPad
        enterOTPMobileNumberTextField.becomeFirstResponder()
    }
    
    @objc func signinOtherAccountTapped(_ sender: Any) {
        
        guard let mobileNumber = enterOTPMobileNumberTextField.text else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        sendOTPDelegate?.getEnteredMobileNumber(mobileNumber)
    }
    
    @objc func sendOTPTapped(_ sender: Any) {
        guard let mobileNumber = enterOTPMobileNumberTextField.text else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
        sendOTPDelegate?.getEnteredMobileNumber(mobileNumber)
    }
}

extension SendOTPView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enterOTPMobileNumberTextField.resignFirstResponder()
        return true
    }
}
