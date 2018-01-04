//
//  EnterKMViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 29/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import PinCodeTextField
import AVFoundation
import Foundation
import Mixpanel

enum kmType {
  case start
  case end
  case standard
}

class EnterKMViewController: UIViewController {

  var type: kmType!

  @IBOutlet weak var useFlashButton: UIButton!

  @IBOutlet weak var enterKMTextFieldView: PinCodeTextField! {
    didSet {
      enterKMTextFieldView.delegate = self
    }
  }

  @IBOutlet weak var confirmButton: UIButton!
  @IBOutlet var titleLabel: UILabel!

  var scannedBike: GoBike!
  var bookingID: String?
  var reading: GoReading!
  var randomNumber = Int(arc4random_uniform(9))
  var forceDrop: Bool?

  var inputToolbar: UIToolbar = {
    var toolbar = UIToolbar()
    toolbar.barStyle = .default
    toolbar.isTranslucent = true
    toolbar.sizeToFit()
    toolbar.isUserInteractionEnabled = false
    return toolbar
  }()

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, type: kmType, bookingID: String?, scannedBike: GoBike?, reading: GoReading, forceDrop: Bool? = nil) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.type = type
    self.bookingID = bookingID
    self.scannedBike = scannedBike
    self.reading = reading
    self.forceDrop = forceDrop
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initialUISetups()
  }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        enterKMTextFieldView.becomeFirstResponder()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        enterKMTextFieldView.resignFirstResponder()
    }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.makeNavigationBarTransparent()
  }


  func initialUISetups() {
    confirmButton.layer.cornerRadius = 0.5 * confirmButton.frame.height
    enterKMTextFieldView.keyboardType = .numberPad
    enterKMTextFieldView.keyboardAppearance = .dark

    switch self.type {
    case .start:
      titleLabel.text = "Enter Start KM"
      guard let reading = reading else {
        return
      }
      Mixpanel.mainInstance().track(event: GoMixPanelEvents.goStartKM, properties: ["Bike Reg No": self.scannedBike.regNo])
      let currentReading = String(describing: reading.current)
      enterKMTextFieldView.characterLimit = reading.current.digitCount + 1
        enterKMTextFieldView.text = currentReading + "\(randomNumber)"
    case .end:
        guard let reading = reading else {
            WheelstreetViews.somethingWentWrongAlertView()
            return
        }
      Mixpanel.mainInstance().track(event: GoMixPanelEvents.goEndKM, properties: ["Bike Reg No": self.scannedBike.regNo])
      titleLabel.text = "Enter End KM"
      let endKmReading = String(describing: reading.current)
      enterKMTextFieldView.characterLimit = reading.maximum.digitCount + 1

      enterKMTextFieldView.text = endKmReading + "\(randomNumber)"
    default:
      titleLabel.text = ""
    }

    enterKMTextFieldView.inputAccessoryView = inputToolbar
    inputToolbar.barTintColor = UIColor.appThemeColor

    if let reading = reading {
      let minimumLabel = UILabel()
      minimumLabel.frame = CGRect(x: 8, y: 0, width: inputToolbar.frame.width/2 - 8, height:  inputToolbar.frame.height)
      minimumLabel.textAlignment = .left
      minimumLabel.font = UIFont.systemFont(ofSize: 17)
      minimumLabel.text = "Minimum: \(reading.minimum)9"
      minimumLabel.textColor = UIColor.white

      inputToolbar.addSubview(minimumLabel)

      let maximumLabel = UILabel()
      maximumLabel.frame = CGRect(x: inputToolbar.frame.width/2, y: 0, width: inputToolbar.frame.width/2 - 8, height:  inputToolbar.frame.height)
      maximumLabel.textAlignment = .right
      maximumLabel.font = UIFont.systemFont(ofSize: 17)
      maximumLabel.text = "Maximum: \(reading.maximum)9"
      maximumLabel.textColor = UIColor.white

      inputToolbar.addSubview(maximumLabel)
    }
  }

  @IBAction func didTapUseFlash(_ sender: Any) {
    guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
      return
    }
    if (captureDevice.hasTorch) {
      do {
        try captureDevice.lockForConfiguration()
        if (captureDevice.torchMode == AVCaptureDevice.TorchMode.on) {
          captureDevice.torchMode = AVCaptureDevice.TorchMode.off
        } else {
          do {
            try captureDevice.setTorchModeOn(level: 1.0)
          } catch {
            print(error)
          }
        }
        captureDevice.unlockForConfiguration()
      } catch {
        print(error)
      }
    }
  }

  @IBAction func didTapConfirm(_ sender: Any) {
      confirmButton.isEnabled = false

      guard let enteredKM: String =  enterKMTextFieldView.text else {
         WheelstreetViews.somethingWentWrongAlertView()
        confirmButton.isEnabled = true
        return
      }
    guard let reading = reading else {
        fatalError("Bike Reading Not Found")
    }
    let finalKMToSend = String(describing: enteredKM.dropLast())
    let enteredKmInt: Int = finalKMToSend.toInt()!
    if enteredKmInt >= reading.minimum, reading.maximum >= enteredKmInt {
        let bikePhotoVC = BikeKMPhotoViewController(nibName: "BikeKMPhotoViewController", bundle: nil, type: self.type, scannedBike: scannedBike, kmInput: finalKMToSend, bookingID: self.bookingID)
        
        UIApplication.navigationController().pushViewController(bikePhotoVC, animated: true)
    } else {
        WheelstreetViews.alertView(title: "Error", message: "Enter a valid number between \(reading.minimum) and \(reading.maximum)")
        return
    }
    
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.view.endEditing(true)
  }
}

extension EnterKMViewController: PinCodeTextFieldDelegate {

  func textFieldValueChanged(_ textField: PinCodeTextField) {
    guard let value = textField.text else {
      WheelstreetViews.alertView(title: "Please input km", message: "")
      return
    }

    confirmButton.isEnabled = !value.isEmpty

    /*
    let minInitial = (reading.minimum/100)%10
    let currentInitial = (reading.current/100)%10
    let maxInitial = (reading.maximum/100)%10

    let minSecondInitial = (reading.minimum/10)%10
    let currentSecondInitial = (reading.current/10)%10
    let maxSecondInitial = (reading.maximum/10)%10

    let minLastDigit = reading.minimum%10
    let currentLastDigit = reading.current%10
    let maxLastDigit = reading.maximum%10

    var allowedDigits: [Int: [Int]] = [Int: [Int]]()

    if minInitial == currentInitial && currentInitial == maxInitial {
      allowedDigits[1] = [minInitial]
    }
    else {
      allowedDigits[1] = [minInitial, maxInitial]
    }

    switch value.count {
    case 1:
      if allowedDigits[1]?.count == 1 {
        if value != "\((allowedDigits[1]?.first)!)" {
          textField.textColor = UIColor.red
          UIView.animate(withDuration: 0.5, animations: {
            textField.text = ""
            textField.textColor = UIColor.white
          })
          break
        }
        else {
          break
        }
      }
      else if allowedDigits[1]?.count == 2 {
        if value.toInt()! >= (allowedDigits[1]?.first!)! && (allowedDigits[1]?.last!)! <= value.toInt()! {
          textField.textColor = UIColor.red
          UIView.animate(withDuration: 0.5, animations: {
            textField.text = ""
            textField.textColor = UIColor.white
          })
        }
      }

    default:
      break
    }
*/
  }
}

