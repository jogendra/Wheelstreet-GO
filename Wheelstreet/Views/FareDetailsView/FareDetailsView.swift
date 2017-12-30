//
//  FareDetailsView.swift
//  Wheelstreet
//
//  Created by JDpawar on 21/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

class FareDetailsView: UIView {
    
    @IBOutlet weak var labelBaseFare: UILabel!
    @IBOutlet weak var labelPerKm: UILabel!
    @IBOutlet weak var labelPerMinute: UILabel!
    @IBOutlet weak var labelPerMinuteBuffer: UILabel!
    
    override func awakeFromNib() {
        // TODO: Call the API and then assign the values
        super.awakeFromNib()
        NSLog("Awake From Nib")
        Network.shared.post("https://api.wheelstreet.org/v1/go/fare-details", params: ["lat": 12.8951532, "lng": 77.6074797, "bikeId": "1510826934953980"], withHeader: true, completion: { parsedJSON, statusCode, error in
            if error != nil {
                print(error as Any)
            } else {
                if let data = parsedJSON, let dataArray = data["data"].dictionary {
                    guard let kmRate = dataArray["kmRate"], let minuteRate = dataArray["minuteRate"], let baseRate = dataArray["baseRate"]
                        else {
                            return
                    }
                    
                    self.labelBaseFare.text = "₹ \(baseRate)"
                    self.labelPerKm.text = "₹ \(kmRate)"
                    self.labelPerMinute.text = "₹ \(minuteRate)"
                    
                    if let perMinuteBuffer = dataArray["minuteOffer"] {
                        self.labelPerMinuteBuffer.text = "• Appicable after \(perMinuteBuffer) min"
                    } else {
                        self.labelPerMinuteBuffer.isHidden = true
                    }
                }
            }
        })
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion:  {
            (value: Bool) in
            self.isHidden = true
        })
    }
}
