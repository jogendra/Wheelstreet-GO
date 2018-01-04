//
//  GOKYCUploadViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 15/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Mixpanel

fileprivate enum Defaults {
  static let uploadString = "Upload"
  static let frontString = "Front"
  static let backString = "Back"
  static let drivingLicense = "Driving License"
  static let confirmString = "Confirm"
  static let cornerRadius: CGFloat = 4.0
}

enum KYCUploadType {
  case front
  case back
  case standard
}

class GOKYCUploadViewController: UIViewController {

  @IBOutlet var titleLabel: UILabel!

  @IBOutlet var placeHolderImageView: UIImageView!

  @IBOutlet var retakeButton: UIButton!
  @IBOutlet var uploadButton: UIButton!

  fileprivate var pickedImage: UIImage? {
    didSet {
      placeHolderImageView.image = pickedImage ?? #imageLiteral(resourceName: "front_dl_placeholder")
      retakeButton(isHidden: false)
      uploadButton(toConfirm: true)
    }
  }

  fileprivate var frontImage: UIImage?
  fileprivate var backImage: UIImage?
  
  lazy var imagePicker: UIImagePickerController = {
    let imagePicker = UIImagePickerController()
    imagePicker.allowsEditing = true
    imagePicker.delegate = self
    return imagePicker
  }()


  var type: KYCUploadType = .standard {
    didSet {
      setTitle()
      pickedImage = nil
      retakeButton(isHidden: true)
      uploadButton(toConfirm: false)
      setPlaceHolderImage()
    }
  }

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, type: KYCUploadType) {
    self.type = type
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setUpInitialViews()
    uploadButton(toConfirm: false)
  }

  fileprivate func setUpInitialViews() {
    retakeButton.isHidden = true
    uploadButton.setTitle(Defaults.uploadString, for: .normal)

    uploadButton.layer.masksToBounds = true
    uploadButton.layer.cornerRadius = Defaults.cornerRadius

    let imageBorder = CAShapeLayer()
    imageBorder.strokeColor = UIColor.black.cgColor
    imageBorder.lineDashPattern = [2, 2]
        imageBorder.masksToBounds = true
    imageBorder.cornerRadius = Defaults.cornerRadius
    imageBorder.frame = placeHolderImageView.bounds
    imageBorder.fillColor = nil
    imageBorder.path = UIBezierPath(rect: placeHolderImageView.bounds).cgPath
    placeHolderImageView.layer.addSublayer(imageBorder)

    setPlaceHolderImage()

    self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissMe)), animated: true)
    self.navigationController?.navigationBar.tintColor = UIColor.appThemeColor
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.shadowImage = UIImage()
  }

  @objc func dismissMe() {
    self.dismiss(animated: true, completion: {
      (UIApplication.shared.delegate as! AppDelegate).getHomePageData()
    })
  }

  fileprivate func setPlaceHolderImage() {
    switch type {
    case .front:
      self.placeHolderImageView.image = #imageLiteral(resourceName: "front_dl_placeholder")
    case .back:
      self.placeHolderImageView.image = #imageLiteral(resourceName: "back_dl_placeholder")
    case .standard:
      self.placeHolderImageView.image = #imageLiteral(resourceName: "front_dl_placeholder")
    }
  }

  fileprivate func setTitle() {
    var titleText: String = Defaults.uploadString
    switch type {
    case .front:
      titleText += " " + Defaults.frontString + " " + Defaults.drivingLicense
    case .back:
      titleText += " " + Defaults.backString + " " + Defaults.drivingLicense
    default:
      break
    }

    titleLabel.text = titleText
  }


  fileprivate func presentUploadImageSheet(cancelationhandler: @escaping((_ action: UIAlertAction) -> ())) {
    Mixpanel.mainInstance().time(event: GoMixPanelEvents.goUploadDL)

    let alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let topViewController = UIApplication.topViewController()
    if let alertVCSubView = alertVC.view.subviews.first?.subviews.first?.subviews.first {
      alertVCSubView.backgroundColor = UIColor.white
    }

    let cameraAction = UIAlertAction(title: GoDefaults.cameraString, style: .default, handler: { [weak self] (action) in
      self?.openCamera()
    })
    cameraAction.setValue(UIColor.appThemeColor, forKey: GoKeys.alertTitleKey)
    alertVC.addAction(cameraAction)

    let galleryAction = UIAlertAction(title: GoDefaults.galleryString, style: .default, handler: { [weak self] (action) in
      self?.openPhotoLibrary()
    })
    galleryAction.setValue(UIColor.appThemeColor, forKey: GoKeys.alertTitleKey)
    alertVC.addAction(galleryAction)

    let cancelAlert = UIAlertAction(title: GoDefaults.cancelString, style: .cancel, handler: cancelationhandler)
    cancelAlert.setValue(UIColor.appThemeColor, forKey: GoKeys.alertTitleKey)
    alertVC.addAction(cancelAlert)

    topViewController?.present(alertVC, animated: true, completion: nil)
  }

  fileprivate func openPhotoLibrary() {
    guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
      WheelstreetViews.bluredAlertView(title: "Something went wrong", message: "Please check your settings")
      return
    }

    imagePicker.sourceType = .photoLibrary

    if let topVC = UIApplication.topViewController() {
      topVC.present(imagePicker, animated: true)
    }
    else {
      present(imagePicker, animated: true)
    }
  }

  fileprivate func openCamera() {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      WheelstreetViews.bluredAlertView(title: "Something went wrong", message: "Please check your settings")
      return
    }

    imagePicker.sourceType = .camera
    imagePicker.cameraCaptureMode = .photo

    if let topVC = UIApplication.topViewController() {
      topVC.present(imagePicker, animated: true)
    }
    else {
      present(imagePicker, animated: true)
    }
  }

  fileprivate func retakeButton(isHidden: Bool) {
    retakeButton.isHidden = isHidden
  }

  fileprivate func uploadButton(toConfirm: Bool) {
    uploadButton.setTitle(toConfirm ? Defaults.confirmString : Defaults.uploadString, for: .normal)

    uploadButton.backgroundColor = toConfirm ? UIColor.appThemeColor : .clear
    uploadButton.setTitleColor(toConfirm ? .white : UIColor.appThemeColor, for: .normal)
    uploadButton.layer.borderWidth = toConfirm ? 0 : 2
    uploadButton.layer.borderColor = UIColor.appThemeColor.cgColor
  }

  fileprivate func uploadImages() {
    WheelstreetAPI.uploadKYC(frontImage: self.frontImage!, backImage: self.backImage!) { (message, status) in
      if let message = message {
        UIApplication.navigationController().presentedViewController?.dismiss(animated: true, completion: {
          if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.getHomePageData()
          }
          else {
            WheelstreetViews.alertView(title: message, message: message)
          }
        })
      }
      else {
        WheelstreetViews.somethingWentWrongAlertView()
      }
    }
  }

  @IBAction func didTapRetakeButton(_ sender: Any) {
      presentUploadImageSheet(cancelationhandler: { [weak self](action) in
        self?.retakeButton(isHidden: false)
      })
  }

  @IBAction func didTapUploadButton(_ sender: Any) {
    if pickedImage == nil {
      presentUploadImageSheet(cancelationhandler: { (action) in })
    }
    else {
      switch type {
      case .front:
        self.frontImage = self.pickedImage
        type = .back
        Mixpanel.mainInstance().track(event: GoMixPanelEvents.goUploadDL, properties: ["Front Uploaded": true, "Back Uploaded": false])
        Mixpanel.mainInstance().time(event: GoMixPanelEvents.goUploadDL)
      case.back:
        self.backImage = self.pickedImage
        Mixpanel.mainInstance().track(event: GoMixPanelEvents.goUploadDL, properties: ["Front Uploaded": true, "Back Uploaded": true])
        uploadImages()
      case .standard:
        break
      }
    }
  }
}

extension GOKYCUploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true)
  }

  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      self.retakeButton(isHidden: true)
      self.pickedImage = pickedImage
    }
    picker.dismiss(animated: true)
  }

}
