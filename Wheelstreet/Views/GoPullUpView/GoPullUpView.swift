//
//  GoPullUpView.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 08/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

protocol GoPullUpViewDelegate: class {
  func presentFareDetailsFor(bike: GoBike)
  func didTapUnlockButtonFor(bike: GoBike)
}

class GoPullUpView: UIView {

  @IBOutlet weak var bikeInfoView: UIView!

  @IBOutlet weak var bikeImageView: UIImageView!

  @IBOutlet weak var bikeModelLabel: UILabel!

  @IBOutlet weak var bikeNumberLabel: UILabel!

  @IBOutlet weak var actionButtonsView: UIView!

  @IBOutlet weak var directionButton: UIButton!

  @IBOutlet weak var unlockButton: UIButton!

  var bike: GoBike? {
    didSet {
      configure()
    }
  }

  weak var pullViewDelegate: GoPullUpViewDelegate?

  override func awakeFromNib() {
    super.awakeFromNib()

    ViewsUISetup()
    ImageViewsSetup()
    ButtonsSetup()

  }


  func configure() {
    guard let bike = self.bike else {
      fatalError("Bike for PullUpVIew not found")
    }

    bikeModelLabel.text = "\(String(describing: bike.bikeMakeName)) \(String(describing: bike.bikeModelName))"
    bikeNumberLabel.text = bike.regNo

    if let bikeModelImageUrl = URL(string: WheelstreetURLs.cdnURL + PublicEndpoints.images.rawValue + PublicEndpoints.bikes.rawValue + PublicEndpoints.web.rawValue + bike.bikeModelImageUrl) {
      bikeImageView.af_setImage(withURL: bikeModelImageUrl)
    }
  }

  func ViewsUISetup() {
    //Action Buttons View UI
    actionButtonsView.layer.shadowColor = UIColor.black.cgColor
    actionButtonsView.layer.shadowOffset = CGSize(width: 0, height: 0)
    actionButtonsView.layer.shadowOpacity = 0.4
    actionButtonsView.layer.shadowRadius = 4.0
    actionButtonsView.layer.cornerRadius = 4.0
    actionButtonsView.layer.masksToBounds = false

    // Bike Info View UI
    bikeInfoView.layer.shadowColor = UIColor.black.cgColor
    bikeInfoView.layer.shadowOffset = CGSize(width: 0, height: 0)
    bikeInfoView.layer.shadowOpacity = 0.4
    bikeInfoView.layer.shadowRadius = 4.0
    bikeInfoView.layer.cornerRadius = 4.0
  }

  func ButtonsSetup() {
    // Direction Button Setup
    let directionButtonImage = UIImage(named: GoImages.directionIcon)
    directionButton.setImage(directionButtonImage, for: .normal)
    directionButton.centerTextAndImage(spacing: 10.0)

    // Unlock Button Setup
    let unlockButtonImage = UIImage(named: GoImages.scanIcon)
    unlockButton.setImage(unlockButtonImage, for: .normal)
    unlockButton.centerTextAndImage(spacing: 10.0)
  }

  func ImageViewsSetup() {
    //Bike Image View Setup
    let bikeImage = UIImage(named: GoImages.activaPlaceholderImage)
    bikeImageView.image = bikeImage
  }

  @IBAction func didTapInfoButton(_ sender: Any) {
    guard let bike = self.bike else {
      fatalError("Bike for PullUpVIew not found")
    }

    pullViewDelegate?.presentFareDetailsFor(bike: bike)
  }

  @IBAction func didTapUnlockButton(_ sender: UIButton) {
    guard let bike = self.bike else {
      fatalError("Bike for PullUpVIew not found")
    }

    pullViewDelegate?.didTapUnlockButtonFor(bike: bike)
  }

  @IBAction func didTapdirectionButton(_ sender: UIButton) {
    guard let bike = self.bike else {
      fatalError("Bike for PullUpVIew not found")
    }

    if let bikeLocation = bike.location {
      WheelstreetCommon.googleMapsDirections(toLocation: bikeLocation) { WheelstreetViews.somethingWentWrongAlertView() }
    }
    else {
      fatalError("Bike Location Not Found")
    }
  }
}
