//
//  UserProfileViewController.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

protocol UserProfileDelegate: class {
    func didTapMapButton()
    func didTapSignOut()
}

class UserProfileView: UIView {
    
    @IBOutlet weak var backToMapButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userMobileNumberLabel: UILabel!
    
    @IBOutlet weak var tripsView: UIView!
    
    @IBOutlet weak var distanceView: UIView!
    
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    
    @IBOutlet weak var distanceCoveredLabel: UILabel!
    
    @IBOutlet weak var drivingLicenseButton: UIButton!
    
    @IBOutlet weak var licenseStatusLabel: UILabel!
    
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var goAppVersionLabel: UILabel!
    
    weak var userProfileDelegate: UserProfileDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        initialUISetups()
        updateUserInformation()
    }
    
    func initialUISetups() {
        // View setups
        tripsView.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        tripsView.layer.borderWidth = 1.0
        distanceView.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        distanceView.layer.borderWidth = 1.0
        tripsView.layer.cornerRadius = 8.0
        distanceView.layer.cornerRadius = 8.0
        
        // label setups
        licenseStatusLabel.layer.cornerRadius = 4.0
        licenseStatusLabel.layer.masksToBounds = true
    }
    
    func updateUserInformation() {
        WheelstreetAPI.getUserProfileDetail(completion: { parsedJSON, statusCode, error in
            switch statusCode {
            case .SUCCESS:
              self.setDefaultsDataToProfile()
            default:
                WheelstreetViews.makeToast(message: WheelstreetAPI.statusToMessage(statusCode))
            }
        })
    }
    
    func setDefaultsDataToProfile() {
        let userDefaults = UserDefaults.standard
        
        guard let name = userDefaults.value(forKey: GoKeys.name), let mobile = userDefaults.value(forKey: GoKeys.mobileNumber), let status = userDefaults.value(forKey: GoKeys.kycStatus) as? String, let trips = userDefaults.value(forKey: GoKeys.bookingCount), let distance = userDefaults.value(forKey: GoKeys.distanceKey) else {
            return
        }
        self.userNameLabel.text = String(describing: name)
        self.userMobileNumberLabel.text = String(describing: mobile)
        self.licenseStatusLabel.text = status
        self.numberOfTripsLabel.text = String(describing: trips)
        self.distanceCoveredLabel.text = "\(distance) KM"
        
        switch status {
        case "Rejacted":
            self.licenseStatusLabel.layer.backgroundColor = UIColor.red.cgColor
        case "Verified":
            self.licenseStatusLabel.layer.backgroundColor = UIColor.green.cgColor
        case "Not Applied":
            self.licenseStatusLabel.layer.backgroundColor = UIColor.red.cgColor
        case "Under Verification":
            self.licenseStatusLabel.layer.backgroundColor = UIColor.orange.cgColor
        default:
            self.licenseStatusLabel.layer.backgroundColor = UIColor.black.cgColor
        }
    }
    
    @IBAction func didTapDrivingLicense(_ sender: Any) {
      if UserDefaults.standard.value(forKey: GoKeys.kycStatus) as? String == "Rejected" {
        WheelstreetViews.statusBarToDefault()
        let kycUploadScreen = GOKYCUploadViewController(nibName: "GOKYCUploadViewController", bundle: nil, type: .front)
        let navigationVC = UINavigationController(rootViewController: kycUploadScreen)
        UIApplication.navigationController().present(navigationVC, animated: true, completion: nil)
      }
    }
    
    @IBAction func backToMapButtonTapped(_ sender: Any) {
        userProfileDelegate?.didTapMapButton()
    }
    
    @IBAction func didTapSignOut(_ sender: Any) {
        GoUserDefaultsService.clearUserDefaults()
        userProfileDelegate?.didTapSignOut()
        UserDefaults.standard.set(false, forKey: GoKeys.isUserLoggedIn)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.setMapAsRoot()
        }
    }
}
