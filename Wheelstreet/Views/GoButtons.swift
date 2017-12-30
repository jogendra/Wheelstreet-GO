//
//  GoButtons.swift
//  Wheelstreet
//
//  Created by JOGENDRA on 08/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

struct GoButtons {
    
    static let userButtonHeight: CGFloat = 48.0
    
    static let userButtonWidth: CGFloat = 48.0
    
    static let helpButtonHeight: CGFloat = 48.0
    
    static let helpButtonWidth: CGFloat = 48.0
    
    static let customerCareButtonHeight: CGFloat = 48.0
    
    static let customerCareButtonWidth: CGFloat = 48.0
    
    static let refreshButtonHeight: CGFloat = 48.0
    
    static let refreshButtonWidth: CGFloat = 48.0
    
    static let unlockButtonHeight: CGFloat = 50.0
    
    static let unlockButtonWidth: CGFloat = 162.0
    
    static let goButtonsShadowRadius: CGFloat = 4.0
    
    static let goButtonsShadowColor: CGColor = UIColor.black.cgColor
    
    static let userbuttonTopAnchorConstant: CGFloat = 22.0
    
    static let userButtonLeadingAnchorConstant: CGFloat = 8.0
    
    static let customerCareButtonBottomAnchorConstant: CGFloat = -8.0
    
    static let refreshButtonBottomAnchorConstant: CGFloat = -86.0
    
    static let buttonsFontSize: CGFloat = 17.0
    
    
    static let userButton: UIButton = {
        let button = UIButton()
        let buttonBackgroundImage = UIImage(named: GoImages.userIcon)
        button.setImage(buttonBackgroundImage, for: .normal)
        button.layer.cornerRadius = 0.5 * userButtonHeight
        button.layer.shadowColor = goButtonsShadowColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = goButtonsShadowRadius
        return button
    }()
    
    static let helpButton: UIButton = {
        let button = UIButton()
        let buttonBackgroundImage = UIImage(named: GoImages.infoIcon)
        button.setImage(buttonBackgroundImage, for: .normal)
        button.layer.cornerRadius = 0.5 * helpButtonHeight
        button.layer.shadowColor = goButtonsShadowColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = goButtonsShadowRadius
        return button
    }()
    
    static let customerCareButton: UIButton = {
        let button = UIButton()
        let buttonBackgroundImage = UIImage(named: GoImages.customerCareIcon)
        button.setImage(buttonBackgroundImage, for: .normal)
        button.layer.cornerRadius = 0.5 * customerCareButtonHeight
        button.layer.shadowColor = goButtonsShadowColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = goButtonsShadowRadius
        return button
    }()
    
    static let refreshButton: UIButton = {
        let button = UIButton()
        let buttonBackgroundImage = UIImage(named: GoImages.refreshIcon)
        button.setImage(buttonBackgroundImage, for: .normal)
        button.layer.cornerRadius = 0.5 * refreshButtonHeight
        button.layer.shadowColor = goButtonsShadowColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = goButtonsShadowRadius
        return button
    }()
    
    static let customMyLocationButton: UIButton = {
        let button = UIButton()
        let buttonBackgroundImage = UIImage(named: GoImages.currentLocationPinIcon)
        button.setImage(buttonBackgroundImage, for: .normal)
        button.layer.cornerRadius = 0.5 * refreshButtonHeight
        button.layer.shadowColor = goButtonsShadowColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = goButtonsShadowRadius
        return button
    }()
    
    static let unlockButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 25.0/255.0, green: 206.0/255.0, blue: 145.0/255.0, alpha: 1.0)
        button.layer.cornerRadius = 0.5 * unlockButtonHeight
        button.setTitle("Unlock", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        let buttonImage = UIImage(named: GoImages.unlockButtonWhiteicon)
        button.setImage(buttonImage, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: buttonsFontSize)
        button.tintColor = UIColor.white
        button.centerTextAndImage(spacing: 10.0)
        return button
    }()
}
