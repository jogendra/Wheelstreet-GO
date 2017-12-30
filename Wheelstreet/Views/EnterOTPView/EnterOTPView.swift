//
//  EnterOTPView.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 14/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import PinCodeTextField

protocol EnterOTPDelegate: class {
    func didTextFieldValueChange(value: String)
    func didTapResendOTPButton()
}

class EnterOTPView: UIView {
    
    weak var enterOTPDelegate: EnterOTPDelegate?
    
    @IBOutlet weak var editNumberForOTPButton: UIButton!
    @IBOutlet weak var resendOTPButton: UIButton!
    @IBOutlet weak var OTPEnterTextField: PinCodeTextField! {
        didSet {
            OTPEnterTextField.delegate = self
        }
    }
    
    @IBOutlet weak var resendTimeCounterLabel: UILabel!
    
    @IBOutlet weak var signinOtherAccountButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resendOTPButton.layer.cornerRadius = 0.5 * resendOTPButton.frame.height
        
        OTPEnterTextField.keyboardType = .numberPad
    }
    
    @IBAction func didTapResendOTP(_ sender: Any) {
        enterOTPDelegate?.didTapResendOTPButton()
    }
    
}

extension EnterOTPView: PinCodeTextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {
        
    }
    
    func textFieldValueChanged(_ textField: PinCodeTextField) {
        let value = textField.text ?? ""
        enterOTPDelegate?.didTextFieldValueChange(value: value)
        print("value changed: \(value)")
    }
    
    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }
}
