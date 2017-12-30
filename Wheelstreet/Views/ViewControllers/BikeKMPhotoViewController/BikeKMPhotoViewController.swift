//
//  BikeKMPhotoViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class BikeKMPhotoViewController: UIViewController {

  @IBOutlet weak var bikeKMCameraView: UIView!

  @IBOutlet weak var takePhotoButton: UIButton!

  @IBOutlet weak var useFlashButton: UIButton!

  var bikeKMImage: UIImage?
  let cameraController = CameraController()

  var kmInput: String!
  var scannedBike: GoBike!
  var type: kmType!
  var bookingID: String?

  init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, type: kmType, scannedBike: GoBike, kmInput: String, bookingID: String?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.type = type
    self.kmInput = kmInput
    self.scannedBike = scannedBike
    self.bookingID = bookingID
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    initialUISetups()
    configureCameraController()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    UIApplication.makeNavigationBarTransparent()
  }

  func initialUISetups() {
    takePhotoButton.layer.cornerRadius = 0.5 * takePhotoButton.frame.height
    bikeKMCameraView.layer.borderWidth = 1.0
    bikeKMCameraView.layer.borderColor = UIColor.white.cgColor
  }

  // Configure camera to open the Camera
  func configureCameraController() {
    cameraController.prepare(completionHandler: { (error) in
      if error != nil {
        return
      }

      let darkLayerView = DarkScannerLayerView(frame: self.view.frame)
      darkLayerView.delegate = self
      try? self.cameraController.displayPreview(on: self.view, darkLayerView: darkLayerView)
    })

    let captureMetaDataOutput = AVCaptureMetadataOutput()
    captureMetaDataOutput.rectOfInterest = bikeKMCameraView.frame
    cameraController.captureSession?.addOutput(captureMetaDataOutput)
  }

  func cropCapturedImage(image: UIImage) -> UIImage {
    let screenWidth = bikeKMCameraView.frame.width
    let screenHeight = bikeKMCameraView.frame.height

    let width: CGFloat = image.size.width
    let height: CGFloat = image.size.height

    let aspectRatio = screenWidth / width

    UIGraphicsBeginImageContext(CGSize(width: screenWidth, height: screenHeight))

    image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width * aspectRatio, height: height * aspectRatio)))

    let cropedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return cropedImage!
  }

  func cropImage(image: UIImage, toRect: CGRect) -> UIImage? {
    // Cropping is available trhough CGGraphics
    let cgImage :CGImage! = image.cgImage
    let croppedCGImage: CGImage! = cgImage.cropping(to: toRect)
    return UIImage(cgImage: croppedCGImage)
  }

  @IBAction func didTapTakePhoto(_ sender: Any) {
    cameraController.captureImage(completion: { (image, error) in
      guard let image = image else {
        WheelstreetViews.bluredAlertView(title: "Alert", message: error as? String ?? "Camera Capture Error")
        return
      }
      self.bikeKMImage = self.cropCapturedImage(image: image)
      guard let bikeKMImage = self.bikeKMImage else {
        WheelstreetViews.bluredAlertView(title: "Error", message: "Image is not loaded")
        return
      }
      self.goToBikePIN(withImage: bikeKMImage)
    })

    // try? cameraController.displayPreview(on: self.view)
  }

  func goToBikePIN(withImage image: UIImage) {
    guard let currentKm = self.kmInput?.toInt(), let bikeId = self.scannedBike?.goBikeId else {
      WheelstreetViews.bluredAlertView(title: "Error", message: "Start KM not found")
      return
    }
    
    switch type {
    case .start:
      WheelstreetAPI.getBikeWithStartM(currentKm: currentKm, goBikeId: bikeId, startKmImage: image, completion: { (goBike, bookingData, parsedJSON, bikePin, code) in
        switch code {
        case .SUCCESS:
          if let responseCode = parsedJSON?[GoKeys.statusCode].int {
            if responseCode == 1 {
              if let bikePinVC = UIStoryboard.bikePinVC() as? BikePinViewController {
                bikePinVC.bikePin = bikePin
                bikePinVC.bookingData = bookingData
                UIApplication.navigationController().pushViewController(bikePinVC, animated: true)
              }
            }
          }
          break
        case .FALIURE:
          if let serverError = parsedJSON?[GoKeys.error].string {
            WheelstreetViews.bluredAlertView(title: "Error", message: serverError)
          }
          self.dismiss(animated: true, completion: nil)
          UIApplication.navigationController().popViewController(animated: true)
          break
        default:
          WheelstreetViews.bluredAlertView(title: "Error", message: WheelstreetAPI.statusToMessage(code))
            self.dismiss(animated: true, completion: nil)
            UIApplication.navigationController().popViewController(animated: true)
        }
      })
    case .end:
      WheelstreetAPI.dropBikeWithEndKM(forBookingID: self.bookingID!.toInt()!, endKm: self.kmInput!.toInt()!, endKmImage: image, forceDrop: true, showEndKm: false, completion: { (reading, extraCharge, safeLocations, trip, status) in
        guard status == .SUCCESS else {
          WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(status))
          return
        }

        if let trip = trip {
          let endTripViewController = EndTripViewController(nibName: "EndTripViewController", bundle: nil, trip: trip)
          
          let appDelegate = UIApplication.shared.delegate as! AppDelegate
          appDelegate.navigationController = UINavigationController(rootViewController: endTripViewController)
          
          UIApplication.topViewController()!.present( UIApplication.navigationController(), animated: true, completion: nil)
        }
      })
    default:
      break
    }

  }

  @IBAction func didTapUseFlash(_ sender: Any) {
    if cameraController.flashMode == .on {
      cameraController.flashMode = .off
    } else {
      cameraController.flashMode = .on
    }
  }
}

extension BikeKMPhotoViewController: DarkScannerLayerViewDelegate {
  func scanningFrame() -> CGRect {
    return self.bikeKMCameraView.frame
  }
}

