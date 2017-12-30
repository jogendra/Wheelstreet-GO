//
//  BikePinViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import AVFoundation

class BikePinViewController: UIViewController {

    @IBOutlet weak var useFlashButton: UIButton!
    
    @IBOutlet weak var bikePINLabel: UILabel!
    
    @IBOutlet weak var tripStartsTimerLabel: UILabel!
    
    @IBOutlet weak var unableFindKeyButton: UIButton!
    
    @IBOutlet weak var goGlowingButton: UIButton!
    var pulsator = Pulsator()
    
    @IBOutlet weak var goButton: UIButton!
    
    var bikePin: String?
    var bookingData: GOBooking?
    fileprivate var GOTimer: Timer?
    fileprivate var seconds: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetups()
        setBikePin()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.layoutIfNeeded()
        initialUISetups()
    }
    
    func initialUISetups() {
        pulsator.start()
        pulsator.numPulse = 5
        pulsator.fromValueForRadius = 0.5
        pulsator.radius = goGlowingButton.bounds.width
        pulsator.backgroundColor = UIColor.goThemeColor.cgColor
        pulsator.repeatCount = Float.infinity
        pulsator.position = CGPoint(x: goGlowingButton.bounds.width*0.5, y: goGlowingButton.bounds.height*0.5)
        goGlowingButton.layer.insertSublayer(pulsator, below: goGlowingButton.layer)
        pulsator.start()
        
        // Add bottom border to unable to find keuyy button
        let bottomBorder = CALayer()
        bottomBorder.backgroundColor = UIColor.white.cgColor
        bottomBorder.frame = CGRect(x: 0, y: unableFindKeyButton.frame.height, width: unableFindKeyButton.frame.width, height: 1.0)
        unableFindKeyButton.layer.addSublayer(bottomBorder)
        
        // circle go button
        goButton.layer.cornerRadius = 0.5 * goButton.frame.height
        goButton.layer.borderWidth = 1.0
        goButton.layer.borderColor = UIColor.black.withAlphaComponent(0.6).cgColor
    }
    
    func setBikePin() {
        guard let bikePin = self.bikePin else {
            return
        }

        bikePINLabel.text = bikePin
        runTimer()
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
    
    // Mark: Timer
    fileprivate func runTimer() {
        seconds = 0
        
        GOTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func updateTimer() {
        if (seconds != 120){
            seconds += 1
            if pulsator.radius > goGlowingButton.frame.width {
                pulsator.stop()
            }
            tripStartsTimerLabel.text = seconds <= 60 ? "1:\(60 - seconds)" : "0:\(120 - seconds)"
        } else if seconds == 120 {
            GOTimer?.invalidate()
            self.goOnTrip()
        }else{
            GOTimer?.invalidate()
        }
    }
    
    // Send user to On Trip Screen
    func goOnTrip() {
        UIApplication.shared.statusBarStyle = .default
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getHomePageData()
    }
    
    @IBAction func didTapGo(_ sender: Any) {
        goOnTrip()
    }
    
    @IBAction func didTapUnableFindKey(_ sender: Any) {
        let  goCustomerCareMobileNumber = "+91-7338-259-460"
        guard let numberURL = URL(string: "tel://" + goCustomerCareMobileNumber) else { return }
        UIApplication.shared.open(numberURL)
    }
}
