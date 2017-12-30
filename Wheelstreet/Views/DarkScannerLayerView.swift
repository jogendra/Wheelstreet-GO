//
//  DarkScannerLayerView.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 13/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit


protocol DarkScannerLayerViewDelegate: class {
  func scanningFrame() -> CGRect
}

class DarkScannerLayerView: UIView {

  weak var delegate: DarkScannerLayerViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.clear
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func draw(_ rect: CGRect) {
    if let scanningFrame = delegate?.scanningFrame() {
      let darkRect = CGRect(origin: self.frame.origin, size: CGSize(width: self.frame.width, height: scanningFrame.origin.y))
      UIColor.black.withAlphaComponent(0.74).setFill()
      UIRectFill(darkRect)

      let smallDarkRect = CGRect(origin:  CGPoint(x: 0, y: scanningFrame.origin.y), size: CGSize(width: 0.5*(self.frame.width - scanningFrame.width), height: scanningFrame.height))
      UIColor.black.withAlphaComponent(0.74).setFill()
      UIRectFill(smallDarkRect)

      let secondSmallDarkRect = CGRect(origin:  CGPoint(x: scanningFrame.maxX, y: scanningFrame.origin.y), size: CGSize(width: 0.5*(self.frame.width - scanningFrame.width), height: scanningFrame.height))
      UIColor.black.withAlphaComponent(0.74).setFill()
      UIRectFill(secondSmallDarkRect)

      UIColor.black.withAlphaComponent(0.0).setFill()
      UIRectFill(scanningFrame)

      let secondDarkRect = CGRect(origin: CGPoint(x: 0, y: scanningFrame.maxY), size: CGSize(width: self.frame.width, height: bounds.height - (scanningFrame.origin.y + scanningFrame.height)))
      UIColor.black.withAlphaComponent(0.74).setFill()
      UIRectFill(secondDarkRect)
    }
  }
}
