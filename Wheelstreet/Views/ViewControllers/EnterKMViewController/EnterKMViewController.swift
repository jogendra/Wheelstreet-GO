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

protocol EnterKMViewDelegate: class {
  func didTextFieldValueChange(value: String)
}

enum kmType {
  case start
  case end
  case standard
}

class EnterKMViewController: UIViewController {

  weak var EnterKMViewDelegate: EnterKMViewDelegate?
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
  var reading: GoReading?

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, type: kmType, bookingID: String?, scannedBike: GoBike?, reading: GoReading? = nil) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.type = type
    self.bookingID = bookingID
    self.scannedBike = scannedBike
    self.reading = reading
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


    switch self.type {
    case .start:
      titleLabel.text = "Enter Start KM"
      guard let reading = reading else {
        return
      }
      let currentReading = String(describing: reading.current)
      enterKMTextFieldView.characterLimit = reading.current.digitCount + 1
        enterKMTextFieldView.text = currentReading + "0"
    case .end:
      titleLabel.text = "Enter End KM"
    default:
      titleLabel.text = ""
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
      guard let enteredKM: String =  enterKMTextFieldView.text else {
         WheelstreetViews.somethingWentWrongAlertView()
        return
      }
    guard let reading = reading else {
        fatalError("Bike Reading Not Found")
    }
    let finalKMToSend = String(describing: enteredKM.dropLast())
    let enteredKmInt: Int = finalKMToSend.toInt()!
    if enteredKmInt > reading.minimum, enteredKmInt < reading.maximum {
        let bikePhotoVC = BikeKMPhotoViewController(nibName: "BikeKMPhotoViewController", bundle: nil, type: self.type, scannedBike: scannedBike, kmInput: finalKMToSend, bookingID: self.bookingID)
        
        UIApplication.navigationController().pushViewController(bikePhotoVC, animated: true)
    } else {
        WheelstreetViews.alertView(title: "Alert", message: "Please enter valid Km. Keep last digit 0")
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
    EnterKMViewDelegate?.didTextFieldValueChange(value: value)
  }
}

