//
//  WheelstreetAPI.swift
//  Wheelstreet
//
//  Created by Kush Taneja on 06/12/17.
//  Copyright © 2017 Kush Taneja. All rights reserved.
//

import Foundation
import Alamofire


//#if DEVELOPMENT
//  fileprivate var testing: Bool = true
//#else
fileprivate var testing: Bool = false
//#endif

public var apiURL = testing ? WheelstreetURLs.testingServerURL : WheelstreetURLs.serverURL


public enum Endpoints: String {
  // MARK: Versions
  case v1 = "v1/"
  
  // MARK: Apps
  case go = "go/"

  // MARK: User Login/ SignUp
  case user = "user/"
  case preSignUp = "pre-signup/"
  case verifyMobileEmail = "verify-mobile-email/"
  case signUp = "signup/"
  case login = "login/"
  case goProfile = "go-profile/"

  //MARK: Go Bikes
  case search = "search/"
  case getCartBikes = "get-cart-bikes/"
  case fareDetails = "fare-details/"
  case homePageData = "home-page-data/"
  case checkBike = "check-bike/"
  case drop = "drop/"
  case pickUp = "pick-up/"
  case retry = "retry/"
  case kyc = "kyc/"
  case applyShare = "apply-share/"
  case helplineNumber = "helpline-number"

  // MARK: CDN
  case images = "images/"
  case bikes = "bikes/"
  case web = "web/"

  //MARK: Payments
  case payment = "payment/"
  case details = "details/"
  case generateChecksum = "generate-checksum/"
}

public enum PublicEndpoints: String {
    // MARK: CDN
    case images = "images/"
    case bikes = "bikes/"
    case web = "web/"
}

enum WheelstreetAPIStatus: Int {
  case SUCCESS          =                 200
  
  case NO_CONTENT_FOUND  =                204

  case FALIURE            =               422

  case INTERNAL_SERVER_ERROR =            500

  case ERR_APP_HTTP_ERROR =               12000

  case ERR_APP_HTTP_RESPONSE =            12001

  case UNKOWN_ERROR         =             1000
}

class WheelstreetAPI {

  static func WheelstreetAPIStatusFor(_ code: Int) -> WheelstreetAPIStatus {

    if 200 ... 299 ~= code {
      return WheelstreetAPIStatus.SUCCESS
    }

    return WheelstreetAPIStatus(rawValue: code) ?? .UNKOWN_ERROR
  }

  static func statusToMessage(_ status: WheelstreetAPIStatus) -> String {
    switch status {
    case .SUCCESS:
      return "Success"
    case .FALIURE:
      return "Something went wrong! Please try Again Later."
    case .ERR_APP_HTTP_ERROR:
      return "Oh no, lost internet connection\n Please retry after some time."
    default:
      return "Looks like our servers cannot be reached. Be sure to check your internet connection."
    }

  }

  // MARK: Login and SignUp




  // MARK: GO Bikes

  class func getFareDetails(forBike bike: GoBike, completion: @escaping((GoFareDetails?, _ minuteOffer: Int?, _ minuteOfferMessage: String?, _ extraCharges: Int?, _ safeLocations: [GOSafeLocation]?, WheelstreetAPIStatus)-> Void)) {
      guard Reachability.isConnectedToNetwork() == true else {
        ActivityIndicator.shared.hideProgressView()
        WheelstreetViews.noInternetConnectionAlertView()
        completion(nil, nil, nil, nil, nil, .ERR_APP_HTTP_ERROR)
        return
      }

      let params: Dictionary<String, Any> = [GoKeys.bikeId: bike.goBikeId]

      Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.fareDetails.rawValue, params: params, withHeader: true) { (data, code, error) in

        ActivityIndicator.shared.hideProgressView()

        if let code = code {
          switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
          case .SUCCESS:
            var goSafeLocations: [GOSafeLocation]?
            var goFareDetails: GoFareDetails?
            if let fareData = data?[GoKeys.data] {
              goFareDetails = GoFareDetails(data: fareData)

              if let dropLocation = fareData["safeLocation"].dictionary {
                goSafeLocations = []
                for (key, value) in  dropLocation {
                  let location = GOSafeLocation(locationTitle: key, data: value)
                  goSafeLocations?.append(location)
                }
              }

              let minuteOffer = fareData[GoKeys.minuteOffer].int
              let minuteOfferMessage = fareData[GoKeys.minuteOfferMessage].string
              let extraCharges = fareData[GoKeys.extraCharges].int
              completion(goFareDetails, minuteOffer, minuteOfferMessage, extraCharges, goSafeLocations, .SUCCESS)
            }
            break
          default:
            completion(nil, nil, nil, nil, nil, WheelstreetAPI.WheelstreetAPIStatusFor(code))
          }
        }
        else {
          completion(nil, nil, nil, nil, nil, .UNKOWN_ERROR)
        }
      }
  }

  class func uploadKYC(frontImage: UIImage, backImage: UIImage, completion: @escaping((_ statusMessage: String?, WheelstreetAPIStatus)-> Void)) {
    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      WheelstreetViews.noInternetConnectionAlertView()
      completion(nil, .ERR_APP_HTTP_ERROR)
      return
    }

    let images: [String: UIImage] = ["dlFrontImage": frontImage, "dlBackImage": backImage]
    Network.shared.uploadFiles(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.kyc.rawValue, images: images, params: nil, withHeader: true, completion: { (data, code, error) in

      guard let data = data else {
        completion(nil, .NO_CONTENT_FOUND)
        return
      }
      
      switch data[GoKeys.statusCode].intValue {
      case 1:
        completion(data[GoKeys.data].string, .SUCCESS)
      default:
        completion(data[GoKeys.error].string, .FALIURE)
      }
    }, progressBlock: { (fraction) in
      ActivityIndicator.shared.updateLablel(text: "\(fraction!*100) %")
    })
  }

  class func getHelpLineNumber() {
    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      if UserDefaults.standard.value(forKey: GoKeys.help) == nil {
        UserDefaults.standard.set("+91-8088400500", forKey: GoKeys.help)
      }
      return
    }

    Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.helplineNumber.rawValue, params: nil, withHeader: false, showActivityIndicator: false) { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        if UserDefaults.standard.value(forKey: GoKeys.help) == nil {
          UserDefaults.standard.set("+91-8088400500", forKey: GoKeys.help)
        }
        return
      }

      if let number = data[GoKeys.data].object as? String {
        UserDefaults.standard.set(number, forKey: GoKeys.help)
      }
      else {
        if UserDefaults.standard.value(forKey: GoKeys.help) == nil {
          UserDefaults.standard.set("+91-8088400500", forKey: GoKeys.help)
        }
      }
    }
  }

  class func homePageData(completion: @escaping((GOBooking?, GOTrip?, [GoBike]?, _ kycStatus: Int?, WheelstreetAPIStatus)-> Void)) {

    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      WheelstreetViews.noInternetConnectionAlertView()
      completion(nil, nil, nil, nil, .ERR_APP_HTTP_ERROR)
      return
    }

    Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.homePageData.rawValue, params: nil, withHeader: true, showActivityIndicator: false) { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, nil, nil, nil, .NO_CONTENT_FOUND)
        return
      }
      var goBooking: GOBooking?
      switch data[GoKeys.statusCode].intValue {
      case 1:
        goBooking = GOBooking(data: data[GoKeys.data])
        completion(goBooking, nil, nil, nil, .SUCCESS)
      case 2:
        let bookingId = data[GoKeys.data]["bookingId"].object as! Int
        getBookingDetails(forBookingID: bookingId, completion: { (trip, status) in
          completion(nil, trip, nil, nil, .SUCCESS)
        })
      case 3:
        let kycStatus = data[GoKeys.data]["kycStatus"].int
        var goBikes: [GoBike] = []
        if let dataArray = data[GoKeys.data]["bikes"].array {
          if !dataArray.isEmpty {
            for bikeData in dataArray {
              goBikes.append(GoBike(data: bikeData))
            }
          }
        }
        completion(nil, nil, goBikes, kycStatus, .SUCCESS)
      case -1:
        Location.shared.locationManagerSetup()
        homePageData(completion: completion)
      default:
        break
      }

    }
  }

  class func dropBike(forBookingID id: Int, forceDrop: Bool? = nil, completion: @escaping((GoReading?, _ extraCharge: Int?, [GOSafeLocation]?, GOTrip?, WheelstreetAPIStatus)-> Void)) {

    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      WheelstreetViews.noInternetConnectionAlertView()
      completion(nil, nil, nil, nil, .ERR_APP_HTTP_ERROR)
      return
    }
    
    var params = Network.defaultParamas()
    params["bookingId"] = id
    if let forceDrop = forceDrop {
      params["forceDrop"] = forceDrop
    }
    params["accessToken"] = Utils().checkNSUserDefault(GoKeys.accessToken)

    Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.drop.rawValue, params: params, withHeader: true) { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, nil, nil, nil, .NO_CONTENT_FOUND)
        return
      }

        if data[GoKeys.statusCode].intValue == -9 {
          let readings = GoReading(data: data["error"]["km"])
          completion(readings, nil, nil, nil, .SUCCESS)
        }
        else if data[GoKeys.statusCode].intValue == -10 {
          var extraCharge: Int?
          var safeLocations: [GOSafeLocation] = []
          var reading: GoReading?
          for (key, value) in data["error"].dictionaryValue {
            if key == "extraCharge" {
              extraCharge = value.int
            }
            else if key == "safeLocation" {
              for (safeKey, safeValue) in value.dictionaryValue {
                safeLocations.append(GOSafeLocation(locationTitle: safeKey, data: safeValue))
              }
            }
            else if key == "km" {
              reading = GoReading(data: value)
            }
          }
          completion(reading, extraCharge, safeLocations, nil, .SUCCESS)
        }
        else if data[GoKeys.statusCode].intValue == 1 {
          let trip = GOTrip(data: data["data"])
          completion(nil, nil, nil, trip, .SUCCESS)
        }
        else {
          completion(nil, nil, nil, nil, .UNKOWN_ERROR)
        }
      }
  }

  class func dropBikeWithEndKM(forBookingID id: Int, endKm: Int, endKmImage: UIImage, forceDrop: Bool? = nil, completion: @escaping((GoReading? , _ extraCharge: Int? , [GOSafeLocation]?, GOTrip?, WheelstreetAPIStatus)-> Void)) {

    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      WheelstreetViews.noInternetConnectionAlertView()
      completion(nil, nil, nil, nil, .ERR_APP_HTTP_ERROR)
      return
    }
    
    var params = Network.defaultParamas()
    params["bookingId"] = id
    if let forceDrop = forceDrop {
      params["forceDrop"] = forceDrop
    }
    params["endKm"] = endKm
    params["accessToken"] = Utils().checkNSUserDefault(GoKeys.accessToken)

    Network.shared.uploadFile(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.drop.rawValue, image: endKmImage, imageName: "endKmImage", params: params, withHeader: true, completion: { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, nil, nil, nil, .NO_CONTENT_FOUND)
        return
      }

      if data[GoKeys.statusCode].intValue == -9 {
        let readings = GoReading(data: data["error"])
        completion(readings, nil, nil, nil, .SUCCESS)
      }
      else if data[GoKeys.statusCode].intValue == -10 {
        var extraCharge: Int?
        var safeLocations: [GOSafeLocation] = []
        var reading: GoReading?
        for (key, value) in data["error"].dictionaryValue {
          if key == "extraCharge" {
            extraCharge = value.int
          }
          else if key == "safeLocation" {
            for (safeKey, safeValue) in value.dictionaryValue {
              safeLocations.append(GOSafeLocation(locationTitle: safeKey, data: safeValue))
            }
          }
          else if key == "km" {
            reading = GoReading(data: value)
          }
        }
        completion(reading, extraCharge, safeLocations, nil, .SUCCESS)
      }
      else if data[GoKeys.statusCode].intValue == 1 {
        let trip = GOTrip(data: data["data"])
        completion(nil, nil, nil, trip, .SUCCESS)
      }
      else {
        completion(nil, nil, nil, nil, .UNKOWN_ERROR)
      }
    }, progressBlock: {_ in 
      // Show Loader Here
    })
  }

  class func getBookingDetails(forBookingID id: Int, completion: @escaping(GOTrip?, WheelstreetAPIStatus)-> Void) {

    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      WheelstreetViews.noInternetConnectionAlertView()
      completion(nil, .ERR_APP_HTTP_ERROR)
      return
    }

    let params: Dictionary<String, Any> = ["bookingId": id]

    Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.retry.rawValue, params: params, withHeader: true) { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, .NO_CONTENT_FOUND)
        return
      }

      if data[GoKeys.statusCode].intValue == 1 {
        let trip = GOTrip(data: data["data"])
        completion(trip, .SUCCESS)
      }
      else {
        completion(nil, .UNKOWN_ERROR)
      }
    }
  }

  // MARK: Payments

  class func getChecksumHash(oderData: Dictionary<String, Any>, completion: @escaping((String?, WheelstreetAPIStatus)-> Void)) {

    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      return
    }

    Network.shared.postWithFormData(url: testing ? WheelstreetURLs.stagingURL : WheelstreetURLs.webURL + Endpoints.payment.rawValue + Endpoints.generateChecksum.rawValue, params: oderData, withHeader: true) { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, .NO_CONTENT_FOUND)
        return
      }

      completion(data["CHECKSUMHASH"].string, .SUCCESS)
    }

  }

  class func verifyPayment(orderId id: String, completion: @escaping(GOTrip?, WheelstreetAPIStatus)-> Void) {

    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      WheelstreetViews.noInternetConnectionAlertView()
      completion(nil, .ERR_APP_HTTP_ERROR)
      return
    }

    let params: Dictionary<String, Any> = ["orderId": id, "type": 6]
  
    Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.payment.rawValue + Endpoints.details.rawValue, params: params, withHeader: true) { (data, code, error) in

      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, .NO_CONTENT_FOUND)
        return
      }

      if data[GoKeys.statusCode].intValue == 1 {
       let orderId = data[GoKeys.data]["paymentId"].object as! Int
        let trip = GOTrip(orderId: orderId, data: data[GoKeys.data]["booking"], status: GOPaymentStatus(rawValue: data[GoKeys.data][GoKeys.statusCode].object as! Int) ?? .initiate)
        completion(trip, .SUCCESS)
      }
      else if data[GoKeys.statusCode].intValue == 0 {
        completion(nil, .FALIURE)
      }
      else {
        completion(nil, .UNKOWN_ERROR)
      }
    }
  }

  class func sharedOnFacebook(bookingId: String, postId: Int, completion: @escaping((_ trip: GOTrip?, _ errorMessage: String?, WheelstreetAPIStatus)-> Void)) {
    guard Reachability.isConnectedToNetwork() == true else {
      ActivityIndicator.shared.hideProgressView()
      return
    }

    let params: [String: Any] = ["bookingId": bookingId, "postId": postId]

    Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.applyShare.rawValue, params: params, withHeader: true) { (data, code, error) in
      ActivityIndicator.shared.hideProgressView()

      guard let data = data else {
        completion(nil, "Something went wrong", .NO_CONTENT_FOUND)
        return
      }

      if data[GoKeys.statusCode].intValue == 1 {
        let trip = GOTrip(data: data["data"])
        completion(trip, data["error"].object as? String ?? nil, .SUCCESS)
      }
      else {
        completion(nil, data["error"].object as? String ?? nil, .UNKOWN_ERROR)
      }
    }
  }

    // MARK: Check First Time User
    class func checkUser() {
        if GoCommon.isFirstTimeUser {
            guard Reachability.isConnectedToNetwork() == true else {
                ActivityIndicator.shared.hideProgressView()
                return
            }
            Network.shared.get(apiURL + Endpoints.v1.rawValue + Endpoints.user.rawValue + Endpoints.getCartBikes.rawValue , params: nil, withHeader: false, completion: { (data, code, error) in
                ActivityIndicator.shared.hideProgressView()
                
                if let code = code {
                    switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
                    case .SUCCESS:
                        if let tokenKey = data?[GoKeys.data].string {
                            UserDefaults.standard.set(tokenKey, forKey: GoKeys.accessToken)
                            UserDefaults.standard.set(false, forKey: GoKeys.isUserLoggedIn)
                        }
                        break
                    default:
                        break
                    }
                } else {
                    
                }
            })
        }
    }


    
    // Mark: Get all bikes to mark on map
    class func getAllBikeLocation(completion: @escaping(([GoBike]?, WheelstreetAPIStatus) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.get(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.search.rawValue, params: nil, withHeader: false, completion: { (data, code, error) in

            if let code = code {
                switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
                case .SUCCESS:
                    var goBikes : [GoBike] = []
                    if let dataArray = data?[GoKeys.data].array {
                        if !dataArray.isEmpty {
                            for bikeData in dataArray {
                                goBikes.append(GoBike(data: bikeData))
                            }
                        }
                        completion(goBikes, .SUCCESS)
                    }
                    break
                default:
                    completion(nil, WheelstreetAPI.WheelstreetAPIStatusFor(code))
                }
            } else {
                completion(nil, .UNKOWN_ERROR)
            }
        })
    }
    
    // MARK : OTP
    class func verifyEnteredOTP(params: Dictionary<String, Any>, completion: @escaping((_ parsedJSON: JSON?, _ statusCode: Int?, _ error: Error?, WheelstreetAPIStatus) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
      
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.user.rawValue + Endpoints.verifyMobileEmail.rawValue, params: params, withHeader: true, showActivityIndicator: false, completion: { (data, code, error) in
            if error != nil {
                completion(nil, code, error, WheelstreetAPI.WheelstreetAPIStatusFor(code!))
            } else {
                completion(data, code, error, WheelstreetAPI.WheelstreetAPIStatusFor(code!))
            }
        })
    }
    
    // MARK: User Signup
    class func userSignup(params: Dictionary<String, Any>, completion: @escaping((_ parsedJSON: JSON?, _ statusCode: Int?, _ error: Error?, WheelstreetAPIStatus) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.user.rawValue + Endpoints.signUp.rawValue, params: params, withHeader: true, completion: { (data, code, error) in
            if error != nil {
                
            } else {
                completion(data, code, error, WheelstreetAPI.WheelstreetAPIStatusFor(code!))
            }
        })
    }
    
    class func userPreSignup(params: Dictionary<String, Any>, completion: @escaping((_ parsedJSON: JSON?, _ statusCode: Int?, _ error: Error?) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.user.rawValue + Endpoints.preSignUp.rawValue, params: params, withHeader: true, completion: { (data, code, error) in
            completion(data, code, error)
        })
    }
    
    // MARK: User Signin
    class func userSignin(params: Dictionary<String, Any>, completion: @escaping((_ parsedJSON: JSON?, _ statusCode: Int?, _ error: Error?, WheelstreetAPIStatus) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.user.rawValue + Endpoints.login.rawValue, params: params, withHeader: true, completion: { (data, code, error) in
            if error != nil {
                
            } else {
                completion(data, code, error, WheelstreetAPI.WheelstreetAPIStatusFor(code!))
            }
        })
    }
    
    // MARK: Check Bike
  class func checkBike(params: Dictionary<String, Any>, completion: @escaping((GoBike?, JSON?, _ error: String?, WheelstreetAPIStatus, Error?) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.checkBike.rawValue, params: params, withHeader: false, completion: { (data, code, error) in
            if let code = code {
                switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
                case .SUCCESS:
                    var bike: GoBike?
                    if let bikeData = data?[GoKeys.data] {
                        bike = GoBike(data: bikeData)
                        completion(bike, data, nil, .SUCCESS, nil)
                    }
                    else if let error = data?[GoKeys.error].string {
                      completion(nil, nil, error, .SUCCESS, nil)
                  }
                    
                default:
                  if let error = data?[GoKeys.error].string {
                    completion(nil, nil, error, .FALIURE, nil)
                  }
                  else {
                    completion(nil, data, "Something Went Wrong", WheelstreetAPI.WheelstreetAPIStatusFor(code), error)
                  }
                }
            } else {
                completion(nil, nil, "Something Went Wrong", .UNKOWN_ERROR, error)
            }
        })
    }
    
    // MARK: User Profile
    class func getUserProfileDetail(completion: @escaping((JSON?, WheelstreetAPIStatus, Error?) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.user.rawValue + Endpoints.goProfile.rawValue, params: nil, withHeader: true, completion: { (data, code, error) in
            if let code = code {
                switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
                case .SUCCESS:
                    if let userData = data?[GoKeys.data] {
                        GoUserDefaultsService.setProfileData(for: GoUser(data: userData, forProfile: true))
                        completion(data, .SUCCESS, error)
                    }
                    
                    break
                default:
                    completion(data, WheelstreetAPI.WheelstreetAPIStatusFor(code), error)
                }
            } else {
                completion(nil, .UNKOWN_ERROR, error)
            }
        })
    }
    
    // MARK: QR Code
    class func getScannedBike(params: Dictionary<String, Any>,completion: @escaping((GoBike?, JSON?, WheelstreetAPIStatus, Error?) -> Void)) {
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            return
        }
        Network.shared.post(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.checkBike.rawValue, params: params, withHeader: false, completion: { (data, code, error) in
            if let code = code {
                switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
                case .SUCCESS:
                    var bike: GoBike?
                    if let bikeData = data?[GoKeys.data] {
                        bike = GoBike(data: bikeData)
                        completion(bike, data, .SUCCESS, nil)
                    }
                default:
                    completion(nil, data, WheelstreetAPI.WheelstreetAPIStatusFor(code), error)
                }
            } else {
                completion(nil, nil, .UNKOWN_ERROR, error)
            }
        })
        
    }
    
    class func getBikeWithStartM(currentKm: Int, goBikeId: Int, startKmImage: UIImage, completion: @escaping((GoBike?, GOBooking?, JSON?, _ bikePin: String?, WheelstreetAPIStatus)-> Void)) {
        
        guard Reachability.isConnectedToNetwork() == true else {
            ActivityIndicator.shared.hideProgressView()
            WheelstreetViews.noInternetConnectionAlertView()
            completion(nil, nil, nil, nil, .ERR_APP_HTTP_ERROR)
            return
        }
        let accessToken = UserDefaults.standard.value(forKey: GoKeys.accessToken) as? String
        let params: Dictionary<String, Any> = ["bikeId": goBikeId, "currentKm": currentKm, "accessToken": accessToken]
        
        Network.shared.uploadFile(apiURL + Endpoints.v1.rawValue + Endpoints.go.rawValue + Endpoints.pickUp.rawValue, image: startKmImage, imageName: "startKmImage", params: params, withHeader: true, completion: { (data, code, error) in
            
            ActivityIndicator.shared.hideProgressView()
            
            guard let data = data else {
                completion(nil, nil, nil, nil, .NO_CONTENT_FOUND)
                return
            }
            if let code = code {
                let defaults = UserDefaults.standard
                let accessToken = defaults.value(forKey: GoKeys.accessToken) as? String
                let userID = defaults.value(forKey: GoKeys.userId) as? Int
                let name = defaults.value(forKey: GoKeys.username) as? String
                let mobile = defaults.value(forKey: GoKeys.mobileNumber) as? String
                let username = defaults.value(forKey: GoKeys.username) as? String
                let email = defaults.value(forKey: GoKeys.email) as? String
                switch WheelstreetAPI.WheelstreetAPIStatusFor(code) {
                case .SUCCESS:
                    var bike: GoBike?
                    var bookingData: GOBooking?
                    let bikeData = data[GoKeys.data][GoKeys.bike]
                        bike = GoBike(data: bikeData)
                    bookingData = GOBooking(data:  data[GoKeys.data][GoKeys.booking], bike: bike, user: GoUser(accessToken: accessToken, userID: userID, userRole: nil, name: name, mobile: mobile, email: email, username: username, bookingCount: nil, distance: nil, kycStatus: nil))
                    let bikePin = bikeData[GoKeys.pin].string
                    bookingData?.pin = bikePin
                    completion(bike, bookingData, data, bikePin, .SUCCESS)
                default:
                    completion(nil, nil, data, nil, WheelstreetAPI.WheelstreetAPIStatusFor(code))
                }
            } else {
                completion(nil, nil, nil, nil, .UNKOWN_ERROR)
            }
            
        }, progressBlock: {_ in
            // Show Loader Here
        })
    }
}
