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

    @IBOutlet var previewView: PreviewView!
    
    @IBOutlet weak var bikeKMCameraView: UIView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var useFlashButton: UIButton!
    
    var bikeKMImage: UIImage?
    let cameraController = CameraController()
    
    var startKm: String?
    var scannedBike: GoBike?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetups()
        configureCameraController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    checkCamera()
    }
    
    // Camera Permission
    func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authStatus {
        case .authorized:
            break
        case .denied: alertToEncourageCameraAccessInitially()
        case .notDetermined: alertPromptToAllowCameraAccessViaSetting()
        default: alertToEncourageCameraAccessInitially()
        }
    }
    
    func alertToEncourageCameraAccessInitially() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Allow Camera", style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func alertPromptToAllowCameraAccessViaSetting() {
        
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Camera access required for capturing photos!",
            preferredStyle: UIAlertControllerStyle.alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) { alert in
            if AVCaptureDevice.devices(for: AVMediaType.video).count > 0 {
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                    DispatchQueue.main.async() {
                        self.checkCamera() } }
            }
            }
        )
        present(alert, animated: true, completion: nil)
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
        guard let currentKm = self.startKm?.toInt(), let bikeId = self.scannedBike?.goBikeId else {
            WheelstreetViews.bluredAlertView(title: "Error", message: "Start KM not found")
            return
        }
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
                    break
                default:
                    WheelstreetViews.bluredAlertView(title: "Error", message: WheelstreetAPI.statusToMessage(code))
                }
        })
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
