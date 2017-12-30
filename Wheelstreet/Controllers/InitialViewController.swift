//
//  InitialViewController.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 28/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

  @IBOutlet var goLogo: UIImageView!

  override func viewDidLoad() {
        super.viewDidLoad()
      goLogo.addPulseAnimation(from: 0.4, to: 1, duration: 0.8, key: "opacity")
    }
}
