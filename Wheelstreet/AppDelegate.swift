//
//  AppDelegate.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 05/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var statusBar: UIView?
  var navigationController: UINavigationController?
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    GMSServices.provideAPIKey(GoDefaults.goGoogleMapsApiKey)
    GMSPlacesClient.provideAPIKey(GoDefaults.goGooglePlacesApiKey)

    self.statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
    UIApplication.shared.statusBarStyle = .lightContent
    self.statusBar?.backgroundColor = UIColor.clear

    checkLoginAndSetRoot()
    return true
  }

  func setMapAsRoot(userStatus: UserStatus? = .notLoggedIn, bikes: [GoBike]? = nil) {
    let homeScreen = HomeViewController(nibName: "HomeViewController", bundle: nil, bikes: bikes)
    let statusView = StatusViewController(nibName: "StatusViewController", bundle: nil, userStatus: userStatus ?? .notLoggedIn, rootVC: homeScreen)
    setAppWitRootAs(vc: statusView)
  }

  func checkLoginAndSetRoot(userStatus: UserStatus? = .notLoggedIn, bikes: [GoBike]? = nil) {
    guard let isLoggedIn: Bool = UserDefaults.standard.value(forKey: GoKeys.isUserLoggedIn) as? Bool else {
      GoUserDefaultsService.set(login: false)
      setLoginAsRoot()
      return
    }

    switch isLoggedIn {
    case true:
      getHomePageData()
      return
    case false:
      if let hasSkipped: Bool = UserDefaults.standard.value(forKey: GoKeys.hasUserSkipped) as? Bool, hasSkipped {
        setMapAsRoot()
        return
      }

      setLoginAsRoot()
      break
    }
  }


  func getHomePageData() {
    WheelstreetAPI.homePageData { [weak self](booking, trip, bikes, kycStatus, status) in
      if status == .SUCCESS {
        if let booking = booking {
          let onTripScreen = OnTripViewController(nibName: "OnTripViewController", bundle: nil, booking: booking)
          UIApplication.shared.statusBarStyle = .default
          self?.setAppWitRootAs(vc: onTripScreen)
          return
        }

        if let trip = trip {
          let tripDetails = EndTripViewController(nibName: "EndTripViewController", bundle: nil, trip: trip)
          UIApplication.shared.statusBarStyle = .default
          self?.setAppWitRootAs(vc: tripDetails)
          return
        }

        if let bikes = bikes, let kycStatus = kycStatus {
          UserDefaults.standard.set(GoUser.convertKYCStatus(userStatus: UserStatus(rawValue: kycStatus) ?? .none), forKey: GoKeys.kycStatus)
          self?.setMapAsRoot(userStatus: UserStatus(rawValue: kycStatus) ?? .none, bikes: bikes)
          return
        }
      }
      else {
        WheelstreetViews.somethingWentWrongAlertView()
      }
    }
  }

  

  func setAppWitRootAs(vc: UIViewController) {
    navigationController = UINavigationController(rootViewController: vc)
    navigationController?.navigationBar.barTintColor = UIColor.white
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    navigationController?.isNavigationBarHidden = true

    self.window!.rootViewController = navigationController
    self.window!.makeKeyAndVisible()
  }

  func setLoginAsRoot() {
    UIApplication.shared.statusBarStyle = .lightContent
    UIView.transition(with: self.window!, duration: 0.5, options: UIViewAnimationOptions.curveEaseOut, animations: {
        self.setAppWitRootAs(vc: UIStoryboard.splashNavigationScreen())
    }) { (canceled) in
      self.window!.makeKeyAndVisible()
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
      /*
       The persistent container for the application. This implementation
       creates and returns a container, having loaded the store for the
       application to it. This property is optional since there are legitimate
       error conditions that could cause the creation of the store to fail.
      */
      let container = NSPersistentContainer(name: "Wheelstreet")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               
              /*
               Typical reasons for an error here include:
               * The parent directory does not exist, cannot be created, or disallows writing.
               * The persistent store is not accessible, due to permissions or data protection when the device is locked.
               * The device is out of space.
               * The store could not be migrated to the current model version.
               Check the error message to determine what the actual problem was.
               */
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      let context = persistentContainer.viewContext
      if context.hasChanges {
          do {
              try context.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
      }
  }

}

