//
//  RefuelView.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 30/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Mixpanel

protocol RefuelViewDelegate: class {
  func didTapDismiss()
  func bikeOTP() -> String
}

class RefuelView: UIView {

  @IBOutlet var otpTextLabel: UILabel!

  weak var delegate: RefuelViewDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    setOTPLabel()
  }

  func setOTPLabel() {
    otpTextLabel.text = delegate?.bikeOTP()
  }

  @IBAction func didTapDismiss(_ sender: Any) {
    Mixpanel.mainInstance().track(event: GoMixPanelEvents.goRefueledBike)
    delegate?.didTapDismiss()
  }
}
