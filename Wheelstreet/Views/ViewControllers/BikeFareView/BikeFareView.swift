//
//  BikeFareViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 23/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import Alamofire

protocol BikeFareViewDelegate: class {
    func didTapFareDetail(bike: GoBike)
    func didTapProceed()
    func didTapScanQR()
}

class BikeFareView: UIView {
    
    weak var bikeFareViewDelegate: BikeFareViewDelegate?
    
    @IBOutlet weak var bikeNameLabel: UILabel!
    
    @IBOutlet weak var bikeNumberLabel: UILabel!
  
    @IBOutlet weak var farePerKMLabel: UILabel!
    
    @IBOutlet weak var fareDetailButton: UIButton!
    
    @IBOutlet weak var proceedButton: UIButton!
    
    @IBOutlet weak var scanQRButton: UIButton!
    
    var bike: GoBike? {
        didSet {
            configure()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initalUISetups()
    }
    
    func configure() {
        guard let bike = self.bike else {
            fatalError("Bike for BikeFare View not found")
        }
        
        
        bikeNameLabel.text = "\(bike.bikeMakeName) \(bike.bikeModelName)"
        bikeNumberLabel.text = "\(bike.regNo)"
        guard let ratePerKm = bike.fareDetail?.kmRate else {
            farePerKMLabel.text = ""
            return
        }
        farePerKMLabel.text = "₹ \(ratePerKm)"
    }
    
    @IBAction func didTapFareDetail(_ sender: Any) {
      bikeFareViewDelegate?.didTapFareDetail(bike: self.bike!)
    }
    
    @IBAction func didTapProceed(_ sender: Any) {
        bikeFareViewDelegate?.didTapProceed()
    }
    
    @IBAction func didTapScanQR(_ sender: Any) {
        bikeFareViewDelegate?.didTapScanQR()
    }
    
    func initalUISetups() {
        proceedButton.layer.cornerRadius = 0.5 * proceedButton.frame.height
    }
}
