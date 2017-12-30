//
//  QRScanViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 13/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {

    var captureDevice: AVCaptureDevice?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    
    
    @IBOutlet weak var scanBikeImageView: UIImageView!
    
    @IBOutlet weak var QRDescriptionLabel: UILabel!
    
    @IBOutlet weak var codeFrameView: UIView!
    
    @IBOutlet weak var bikeIDManuallyButton: UIButton!
    
    @IBOutlet weak var useFlashButton: UIButton!
    
    @IBOutlet weak var scanQRCodeLabel: UILabel!
    
    @IBOutlet weak var bikeIDManuallyLabel: UILabel!
    
    @IBOutlet weak var useFlashLabel: UILabel!
    
    var tappedBike: GoBike?
    var scannedBike: GoBike?
    var bikeId: Int?
    var bikeReading: GoReading?
    
    var bikeFareView = Bundle.main.loadNibNamed("BikeFareView", owner: self, options: nil)?.first as? BikeFareView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UISetups()
        captureDeviceSetup()
    
        self.navigationController?.title = "GO"
    }

    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      UIApplication.makeNavigationBarTransparent()
    }
    
    func captureDeviceSetup() {
        captureDevice = AVCaptureDevice.default(for: .video)
        if let captureDevice = captureDevice {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                captureSession = AVCaptureSession()
                guard let captureSession = captureSession else {
                    return
                }
                captureSession.addInput(input)
                
                let captureMetaDataOutput = AVCaptureMetadataOutput()
                // captureMetaDataOutput.rectOfInterest = codeFrameView.frame
                captureSession.addOutput(captureMetaDataOutput)
                
                captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: .main)
                captureMetaDataOutput.metadataObjectTypes = [.code128, .qr, .ean13, .ean8, .code39]
                captureSession.startRunning()
                
                self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                self.videoPreviewLayer?.videoGravity = .resizeAspectFill
                self.videoPreviewLayer?.frame = view.layer.bounds
                if let videoPreviewLayer = videoPreviewLayer {
                    view.layer.insertSublayer(videoPreviewLayer, at: UInt32(0))
                    let darkLayerView = DarkScannerLayerView(frame: self.view.frame)
                    darkLayerView.delegate = self
                    view.insertSubview(darkLayerView, at: 1)
                }
            } catch {
                debugPrint("Error Device Input")
            }
        }
    }

    func UISetups() {
        codeFrameView.layer.borderWidth = 3.0
        codeFrameView.layer.borderColor = UIColor(red: 25.0/255.0, green: 206.0/255.0, blue: 145.0/255.0, alpha: 1.0).cgColor
    }
    
    
    @IBAction func toggleFlash(_ sender: Any) {
        
        guard let captureDevice = captureDevice else {
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
    
    @IBAction func didTapBikeIdManually(_ sender: Any) {
        if let bikeIDVC = UIStoryboard.bikeIDVC() as? BikeIDViewController {
            bikeIDVC.tappedBike = self.tappedBike
          UIApplication.navigationController().pushViewController(bikeIDVC, animated: true)
        }
    }
    
    func proceedBike(bike: GoBike, statusCode: Int, goReading: GoReading) {
        if statusCode == 1 {
            if self.tappedBike != nil {
              let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .start, bookingID: nil, scannedBike: self.tappedBike!)
                enterKMVC.reading = goReading
              UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
                }
              else {
                showBikeFareView(with: bike)
            }
      }
    }
    
    func showBikeFareView(with bike: GoBike) {
        guard let bikeFareView = bikeFareView else {
            return
        }
        bikeFareView.layer.opacity = 0.4
        UIView.animate(withDuration: 0.3, animations: {
            bikeFareView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(bikeFareView)
            bikeFareView.bike = bike
            bikeFareView.bikeFareViewDelegate = self
            bikeFareView.layer.opacity = 1.0
        })
    }
    
    func handleScannedQR(for bikeId: String) {
//        guard let currentLocation = Location.shared.currentLocation else {
//            WheelstreetViews.bluredAlertView(title: "Error", message: "Please give access to location to proceed")
//            return
//        }
        
        let params: Dictionary<String, Any> = [GoKeys.bikeId: bikeId, "lat": 12.8951532, "lng": 77.6074797]
        
        WheelstreetAPI.getScannedBike(params: params, completion: { goBike, parsedJSON, code, error in
            if error != nil {
                WheelstreetViews.makeToast(message: "Error. Try again")
            } else {
                switch code {
                case .SUCCESS:
                    if let bike = goBike, let responseCode = parsedJSON?[GoKeys.statusCode].int, let bikeKmData = parsedJSON?[GoKeys.data]["km"] {
                        let goReading = GoReading(data: bikeKmData)
                        self.scannedBike = bike
                        self.bikeReading = goReading
                        self.proceedBike(bike: bike, statusCode: responseCode, goReading: goReading)
                        self.tappedBike = bike
                    }
                default:
                    if let serverError = parsedJSON?[GoKeys.error].string {
                        WheelstreetViews.alertView(title: "Error", message: serverError)
                    } else {
                        WheelstreetViews.alertView(title: "Error", message: WheelstreetAPI.statusToMessage(code))
                    }
                    self.captureDeviceSetup()
                }
            }
        })
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 {
            debugPrint("No Input Detected")
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        view.addSubview(codeFrameView)
        
//        guard let qrcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else {
//            return
//        }
        guard let stringValue = metadataObject.stringValue else {
            return
        }
        captureSession?.stopRunning()
        // handle the Scanned QR code
        self.handleScannedQR(for: stringValue)
        
    }
}


extension ScannerViewController: DarkScannerLayerViewDelegate {
    func scanningFrame() -> CGRect {
        return codeFrameView.frame
    }
}

extension ScannerViewController: BikeFareViewDelegate {
    func didTapFareDetail(bike: GoBike) {
      let fareDetailsVC = FareDetailsViewController(nibName: "FareDetailsViewController", bundle: nil, bike: bike)
      UIApplication.navigationController().present(fareDetailsVC, animated: true, completion: nil)
    }
    
    func didTapProceed() {
        let enterKMVC = EnterKMViewController(nibName: "EnterKMViewController", bundle: nil, type: .start, bookingID: nil, scannedBike: self.scannedBike!, reading: self.bikeReading)
      UIApplication.navigationController().pushViewController(enterKMVC, animated: true)
    }
    
    func didTapScanQR() {
        bikeFareView?.removeFromSuperview()

        captureSession!.startRunning()
    }
    
    
}
