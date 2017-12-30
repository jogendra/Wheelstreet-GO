import UIKit
import Foundation
import Alamofire
import AlamofireImage

fileprivate struct Defaults {
  static let timeoutInternval: TimeInterval = 20
}

class Network {

  static let shared = Network()

  // MARK: GET
    
  func get(_ url: String, params: Dictionary<String, Any>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, _ error: Error?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    WheelstreetViews.networkActivityIndicator(visible: true)

    var finalParams: Dictionary<String, Any> = defaultParamas()
    if let params = params {
      finalParams.unionInPlace(dictionary: params)
    }

    Alamofire.request(url, method : .get, parameters: finalParams, headers: withHeader ? headers : nil)
      .responseJSON { response in
        WheelstreetViews.networkActivityIndicator(visible: false)

        switch response.result {
        case .success:
          if let value = response.result.value, let satusCode = response.response?.statusCode {
            let parsedJson = JSON(value)
            print("getRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) VALUE: \(parsedJson)")
            completion(parsedJson, satusCode, nil)
          }
        case .failure(let error):
            completion(nil, response.response?.statusCode, error)
            print("getRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) ERROR: \(error)")
          }
      }
    }

  // MARK: POST
    
  func post(_ url: String, params: Dictionary<String, Any>?, encoding: ParameterEncoding? = JSONEncoding.default, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    WheelstreetViews.networkActivityIndicator(visible: true)

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    var finalParams: Dictionary<String, Any> = defaultParamas()
    if let params = params {
      finalParams.unionInPlace(dictionary: params)
    }


    Alamofire.request(url as URLConvertible, method: .post, parameters: finalParams, encoding: encoding ?? JSONEncoding.default, headers: withHeader ? headers : nil).validate(statusCode: 200..<500).responseJSON { response in

        WheelstreetViews.networkActivityIndicator(visible: false)

        switch response.result {
        case .success:
          if let value = response.result.value, let satusCode = response.response?.statusCode {
            let parsedJson = JSON(value)
            print("postRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) VALUE: \(parsedJson)")
            completion(parsedJson, satusCode, nil)
          }
        case .failure(let error):
          completion(nil, response.response?.statusCode, error)
          print("postRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) ERROR: \(error)")
        }

      }
    }

  func postWithFormData(url: String, params: Dictionary<String, Any>?, encoding: ParameterEncoding? = JSONEncoding.default, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    WheelstreetViews.networkActivityIndicator(visible: true)

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval


    Alamofire.upload(multipartFormData: {
      multipartFormData in

      if let params = params {
      for (key, value) in params {
        if let value = "\(value)".data(using: .utf8) {
          multipartFormData.append(value, withName: key)
        }
        }
      }
    },
                     to: url as URLConvertible,
                     method: .post,
                     headers: withHeader ? headers : nil,
                     encodingCompletion: { encodingResult in
                      switch encodingResult {
                      case .success(let upload, _, _):
                        upload.uploadProgress(closure: { (progress) in
                          print("Upload Progress: \(progress.fractionCompleted)")
                        })

                        upload.responseJSON { response in
                          WheelstreetViews.networkActivityIndicator(visible: false)


                          switch response.result {
                          case .success(let value):
                            if let satusCode = response.response?.statusCode {
                              let parsedJson = JSON(value)
                              completion(parsedJson, satusCode, nil)
                            }
                          case .failure(let error):
                            completion(nil, response.response?.statusCode, error)
                          }
                        }
                      case .failure(let encodingError):
                        print("Multipart Encoding Error \(encodingError)")
                        completion(nil, nil, encodingError)
                      }
    })
  }

  // MARK: PUT
  func put(_ url: String, params: Dictionary<String, Any>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()
    
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    WheelstreetViews.networkActivityIndicator(visible: true)

    var finalParams: Dictionary<String, Any> = defaultParamas()
    if let params = params {
      finalParams.unionInPlace(dictionary: params)
    }

    Alamofire.request(url as URLConvertible, method: .put, parameters: finalParams, encoding: JSONEncoding.default, headers: withHeader ? headers : nil).validate()
      .responseJSON { response in

        WheelstreetViews.networkActivityIndicator(visible: false)
        switch response.result {
        case .success:
          if let value = response.result.value, let satusCode = response.response?.statusCode {
            let parsedJson = JSON(value)
            print("putRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) VALUE: \(parsedJson)")
            completion(parsedJson, satusCode, nil)
          }
        case .failure(let error):
          completion(nil, response.response?.statusCode, error)
          print("putRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) ERROR: \(error)")
        }
        
    }
  }

  // MARK: PATCH
  func patch(_ url: String, params: Dictionary<String, Any>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    WheelstreetViews.networkActivityIndicator(visible: true)

    var finalParams: Dictionary<String, Any> = defaultParamas()
    if let params = params {
      finalParams.unionInPlace(dictionary: params)
    }

    Alamofire.request(url as URLConvertible, method: .patch, parameters: finalParams, encoding: JSONEncoding.default, headers: withHeader ? headers : nil).validate()
      .responseJSON { response in

        WheelstreetViews.networkActivityIndicator(visible: false)

        switch response.result {
        case .success:
          if let value = response.result.value, let satusCode = response.response?.statusCode {
            let parsedJson = JSON(value)
            print("patchRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) VALUE: \(parsedJson)")
            completion(parsedJson, satusCode, nil)
          }
        case .failure(let error):
          completion(nil, response.response?.statusCode, error)
          print("patchRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) ERROR: \(error)")
        }

    }
  }

  // MARK: DELETE
  func delete(_ url: String, params: Dictionary<String, Any>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    WheelstreetViews.networkActivityIndicator(visible: true)

    var finalParams: Dictionary<String, Any> = defaultParamas()
    if let params = params {
      finalParams.unionInPlace(dictionary: params)
    }

    Alamofire.request(url as URLConvertible, method: .delete, parameters: finalParams, encoding: JSONEncoding.default, headers: withHeader ? headers : nil).validate()
      .responseJSON { response in
        WheelstreetViews.networkActivityIndicator(visible: false)

        switch response.result {
        case .success:
          if let value = response.result.value, let satusCode = response.response?.statusCode {
            let parsedJson = JSON(value)
            print("putRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) VALUE: \(parsedJson)")
            completion(parsedJson, satusCode, nil)
          }
        case .failure(let error):
          completion(nil, response.response?.statusCode, error)
          print("putRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (response.response?.statusCode))) ERROR: \(error)")
        }
        
    }
  }

  //MARK: UPLOAD

  func uploadFile(_ url: String, image: UIImage, imageName: String, params: Dictionary<String, Any>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void, progressBlock: @escaping(_ fraction: Int?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    guard let uploadurl: URLConvertible = URL(string: url) else {
      return
    }

    WheelstreetViews.networkActivityIndicator(visible: true)

    let imageData: Data =  UIImageJPEGRepresentation(image, 0.2)!

    Alamofire.upload(multipartFormData: {
      multipartFormData in
      multipartFormData.append(imageData, withName: imageName, fileName: "attachment_ios_\(Date().timeIntervalSince1970).jpg", mimeType: "image/jpg")
      var finalParams: Dictionary<String, Any> = self.defaultParamas()
      if let params = params {
        finalParams.unionInPlace(dictionary: params)
      }
      
      for (key, value) in finalParams {
        if let value = "\(value)".data(using: .utf8) {
          multipartFormData.append(value, withName: key)
        }
      }
      },
      to: uploadurl,
      method: .post,
      headers: withHeader ? headers : nil,
         encodingCompletion: { encodingResult in
          switch encodingResult {
          case .success(let upload, _, _):

            upload.uploadProgress(closure: { (progress) in
              progressBlock(Int(progress.fractionCompleted))
              print("Upload Progress: \(progress.fractionCompleted)")
            })

            upload.responseJSON { response in
              WheelstreetViews.networkActivityIndicator(visible: false)

              let code = response.response?.statusCode

              switch response.result {
              case .success(let value):
                let parsedJson = JSON(value)
                print("Image Uplaod Success : \(parsedJson)")
                completion(parsedJson, code, nil)
              case .failure(let error):
                print("Image Uplaod Error \(error)")
                completion(nil, code, error)
              }
            }
          case .failure(let encodingError):
            print("Multipart Encoding Error \(encodingError)")
            completion(nil, nil, encodingError)

          }
      })
  }

  func uploadFileWithPatch(_ url: String, image: UIImage, imageName: String, params: Dictionary<String, AnyObject>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void, progressBlock: @escaping(_ fraction: Int?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    guard let uploadurl : URLConvertible = URL(string: url) else {
      return
    }

    WheelstreetViews.networkActivityIndicator(visible: true)

    let imageData: Data =  UIImageJPEGRepresentation(image, 0.2)!

    Alamofire.upload(multipartFormData: {
      multipartFormData in
      multipartFormData.append(imageData, withName: imageName, fileName: "attachment_ios_\(Date().timeIntervalSince1970).jpg", mimeType: "image/jpg")
      if let params = params {
        for (key, value) in params {
          if let value = "\(value)".data(using: .utf8) {
            multipartFormData.append(value, withName: key)
          }
        }
      }
    },               to: uploadurl,
                     method: .patch,
                     headers: withHeader ? headers : nil,
                     encodingCompletion: { encodingResult in
                      switch encodingResult {
                      case .success(let upload, _, _):

                        upload.uploadProgress(closure: { (progress) in
                          progressBlock(Int(progress.fractionCompleted))
                          print("Upload Progress: \(progress.fractionCompleted)")
                        })

                        upload.responseJSON { response in
                          let code = response.response?.statusCode
                          WheelstreetViews.networkActivityIndicator(visible: false)

                          switch response.result {
                          case .success(let value):
                            let parsedJson = JSON(value)
                            print("Image Uplaod Success : \(parsedJson)")
                            completion(parsedJson, code, nil)
                          case .failure(let error):
                            print("Image Uplaod Error \(error)")
                            completion(nil, code, error)
                          }
                        }
                      case .failure(let encodingError):
                        print("Multipart Encoding Error \(encodingError)")
                        completion(nil, nil, encodingError)
                        
                      }
    })
  }

  func uploadFiles(_ url: String, images: [String: UIImage], params: Dictionary<String, Any>?, withHeader: Bool, completion: @escaping (_ parsedJSON: JSON?, _ statusCode: Int?, Error?) -> Void, progressBlock: @escaping(_ fraction: Int?) -> Void) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    guard let uploadurl: URLConvertible = URL(string: url) else {
      return
    }

    WheelstreetViews.networkActivityIndicator(visible: true)

    var imageData: [String: Data] = [:]
    for (name, image) in images {
      imageData[name] = UIImageJPEGRepresentation(image, 0.2)!
    }

    Alamofire.upload(multipartFormData: {
      multipartFormData in
      for (name, imageData) in imageData {
        multipartFormData.append(imageData, withName: name, fileName: "\(name).png", mimeType: "image/png")
      }
      var finalParams: Dictionary<String, Any> = self.defaultParamas()
      if let params = params {
        finalParams.unionInPlace(dictionary: params)
      }

      for (key, value) in finalParams {
        if let value = "\(value)".data(using: .utf8) {
          multipartFormData.append(value, withName: key)
        }
      }
    },
                     to: uploadurl,
                     method: .post,
                     headers: withHeader ? headers : nil,
                     encodingCompletion: { encodingResult in
                      switch encodingResult {
                      case .success(let upload, _, _):

                        upload.uploadProgress(closure: { (progress) in
                          progressBlock(Int(progress.fractionCompleted))
                          print("Upload Progress: \(progress.fractionCompleted)")
                        })

                        upload.responseJSON { response in
                          WheelstreetViews.networkActivityIndicator(visible: false)

                          let code = response.response?.statusCode

                          switch response.result {
                          case .success(let value):
                            let parsedJson = JSON(value)
                            print("Image Uplaod Success : \(parsedJson)")
                            completion(parsedJson, code, nil)
                          case .failure(let error):
                            print("Image Uplaod Error \(error)")
                            completion(nil, code, error)
                          }
                        }
                      case .failure(let encodingError):
                        print("Multipart Encoding Error \(encodingError)")
                        completion(nil, nil, encodingError)

                      }
    })
  }



  //MARK: Download

  func downloadImage(_ url: URL, withHeader: Bool, completion: @escaping((UIImage?, Int?,  Error?)-> Void)) {

    let headers: HTTPHeaders = getAuthorizationHeader()

    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = Defaults.timeoutInternval
    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = Defaults.timeoutInternval

    WheelstreetViews.networkActivityIndicator(visible: true)

    Alamofire.request( url, method : .get, headers: withHeader ? headers : nil ).responseImage { (response) in

      WheelstreetViews.networkActivityIndicator(visible: false)

      let code = response.response?.statusCode

      switch response.result {
      case .success:
        if let image = response.result.value {
          print("getRequest SUCCESS URL : \(url) \n STATUS : \(String(describing: (code))) IMAGE: \(image)")
          completion(image, code, nil)
        }
      case .failure(let error):
        completion(nil, code, error)
        print("getRequest FALIURE URL : \(url) \n STATUS : \(String(describing: (code))) ERROR: \(error)")
      }
    }
  }

  func getAuthorizationHeader() -> Dictionary<String,String> {
    let token = Utils().checkNSUserDefault(GoKeys.accessToken)
    let header: Dictionary<String,String> = ["Content-Type": "application/json", "Authorization" : "Bearer  \(token)"]
    return header
  }

  func defaultParamas() -> Dictionary<String,Any> {
    var sourceParam: Dictionary<String,Any> = ["source": 3]
    sourceParam["lat"] = 12.8951532 // Location.shared.userCurrentLocation()?.coordinate.latitude
    sourceParam["lng"] = 77.6074797 // Location.shared.userCurrentLocation()?.coordinate.longitude
    return sourceParam
  }
}
