//
//  ResetPasswordViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 15/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var resetNewPasswordTextField: HoshiTextField!
    
    @IBOutlet weak var resetConfirmPasswordTextField: HoshiTextField!
    
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicUISetups()
    }
    
    func basicUISetups() {
        resetPasswordButton.layer.cornerRadius = 0.5 * resetPasswordButton.frame.height
    }

}
