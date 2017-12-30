//
//  UIView+Reusable.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 15/07/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit

protocol WheelstreetReusableView: class {
  static var defaultReuseIdentifier: String { get }
}

extension WheelstreetReusableView where Self: UIView {
  static var defaultReuseIdentifier: String {
    return String(describing:self)
  }
}

protocol NibLoadableView: class {
  static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
  static var nibName: String {
    return String(describing: self)
  }
}

extension UITableView {

  func register<T: UITableViewCell>(_: T.Type) where T: WheelstreetReusableView {
    register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
  }


  func register<T: UITableViewCell>(_: T.Type) where T: WheelstreetReusableView, T: NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)

    register(nib, forCellReuseIdentifier: T.defaultReuseIdentifier)
  }

  func dequeReusableCell<T: UITableViewCell>() -> T where T: WheelstreetReusableView {
    guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier) as? T else {
      fatalError("Could not dequeue cell with identifier \(T.defaultReuseIdentifier)")
    }

    return cell
  }

  func dequeReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: WheelstreetReusableView {
    guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier \(T.defaultReuseIdentifier)")
    }

    return cell
  }

}

extension UICollectionView {

  func register<T: UICollectionViewCell>(_: T.Type) where T: WheelstreetReusableView {
    register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
  }

  func register<T: UICollectionViewCell>(_: T.Type) where T: WheelstreetReusableView, T:NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)

    register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
  }

  func dequeReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: WheelstreetReusableView {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
      fatalError("Could not dequeue cell with identifier \(T.defaultReuseIdentifier)")
    }

    return cell
  }
}

