//
//  HTTPClient.swift
//  Harris Teeter
//
//  Created by Verma Mukesh on 21/07/17.
//  Copyright © 2017 Verma Mukesh All rights reserved.
//

import Foundation
import Alamofire
import CommonCrypto

var shouldUseStaticToken: Bool = true

typealias CompletionHandler = (HTDataResponse<Any>?) -> Void

public enum HttpStatusCode : Int {
  case OK = 200                       // /GET, /DELETE result is successful
  case CREATED = 201                  // /POST or /PUT is successful
  case NOT_MODIFIED = 304             // If caching is enabled and etag matches with the server
  case BAD_REQUEST = 400              // Possibly the parameters are invalid
  case INVALID_CREDENTIAL = 401       // INVALID CREDENTIAL, possible invalid token
  case FORBIDDEN = 403                // Server understood the request but refuses to authorize it.
  case NOT_FOUND = 404                // The item you looked for is not found
  case REQUEST_TIMEOUT = 408          // server did not receive a complete request message within the time that it was prepared to wait.
  case CONFLICT = 409                 // Conflict - means already exist
  case AUTHENTICATION_EXPIRED = 419   // Expired
  case INTERNAL_SERVER_ERROR = 500    // server encountered an unexpected condition that prevented it from fulfilling the request.
  
}

public enum CallbackErrorType: Error {
  case UnknownError
  case AlreadyExist // Resource does already exist
  case NotExist // Resource does NOT exist
  case InvalidParameters // The parameter(s) is/are invalid
  case InvalidCredentials // Credentials are invalid
  case Forbidden // Server understood the request but refuses to authorize it.
  case RequestTimeout // server did not receive a complete request message within the time that it was prepared to wait.
  case AccessTokenTimeout // Access Token for the user is timed out
  case APIEndpointNotAvailable // The API endpoint is not available
  case InvalidCsrfToken // Invalid Csrf Token (possibly not exist, or expired)
  case InternalServerError // server encountered an unexpected condition that prevented it from fulfilling the request.
}

public enum CallbackResultType {
  case success(Any?)
  case failure(Error?)
}

class HTTPClient {
  
  fileprivate let localCertHash: [String] =
    ["xyz",
     "pqr"]
  
  public static let sharedManager: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    //    configuration.timeoutIntervalForRequest = 60 // Default is 60
    
    let manager = Alamofire.SessionManager(configuration: configuration)
    return manager
  }()
  
  private func sha256(data : Data) -> String {
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    if (CC_SHA256((data as NSData).bytes , CC_LONG(data.count), &hash) != nil) {
      var hashString: String = ""
      for byte in hash {
        hashString += String(format:"%02x", UInt8(byte))
      }
      print(hashString)
      return hashString
    }
    return ""
  }
  
  private func isValidCertHash(certHash: String) -> Bool {
    print("Cert Hash => \(certHash)")
    return localCertHash.contains(certHash)
  }
  
  func validateSSLFingerprint() {
    let delegate: Alamofire.SessionDelegate = HTTPClient.sharedManager.delegate
    
    delegate.sessionDidReceiveChallenge = { session, challenge in
      var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
      var credential: URLCredential?
      
      if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
        let host = challenge.protectionSpace.host
        
        if let serverTrust = challenge.protectionSpace.serverTrust {
          let serverTrustPolicy = ServerTrustPolicy.performDefaultEvaluation(validateHost: true)
          
          if serverTrustPolicy.evaluate(serverTrust, forHost: host) {
            disposition = .useCredential
            credential = URLCredential(trust: serverTrust)
          } else {
            disposition = .cancelAuthenticationChallenge
            return (disposition, credential)
          }
          
          print("count of certs => \(SecTrustGetCertificateCount(serverTrust))")
          if let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let serverCertificateData:NSData = SecCertificateCopyData(certificate)
            if self.isValidCertHash(certHash: self.sha256(data: serverCertificateData as Data)) {
              disposition = .useCredential
              credential = URLCredential(trust: serverTrust)
            } else {
              disposition = .cancelAuthenticationChallenge
              return (disposition, credential)
            }
          } else {
            disposition = .cancelAuthenticationChallenge
            return (disposition, credential)
          }
        }
      }
      return (disposition, credential)
    }
  }
  /**
   This method sends a request to given url in order to fetch/update data
   - parameters:
   - router: consist of
   - Base url
   - API endpoint
   - Headers
   - HTTP method
   - Version
   - Parameters
   - URL encoding type
   - callback: The callback handler to provide the result of the fetched data
   */
  func response(router: Router, callback: @escaping (CompletionHandler)) -> Void {
    // Validate SSL Fingerprint
    // We can integrate SSL Pinning like how the below function is doing
//    validateSSLFingerprint()
    
    // Confirm Request Adpter
    HTTPClient.sharedManager.adapter = nil
    
    let request = HTTPClient.sharedManager.request(router)
    debugPrint(request)
    print("Should Retry ", router.shouldRetry, router.path)
    // Send request
    request.validate(statusCode: 200..<600).responseJSON { response in
      debugPrint(response)
      
      switch (response.result) {
      case .success:
        APIResponse.init(dataResponse: response).responseAPI(completionHandler: { dataResponse in
          
          let status = response.response!.statusCode;
          if status == HttpStatusCode.REQUEST_TIMEOUT.rawValue {
            // Server Request timeout
            callback(dataResponse)
          } else {
            debugPrint(dataResponse)
            if let apiError = dataResponse.error as? APIError {
              callback(dataResponse)
            } else {
              // Return api response of API error.
              callback(dataResponse)
            }
          }
        });
        break
      case .failure(let error):
        if error._code == NSURLErrorTimedOut {
          //HANDLE TIMEOUT HERE
          
        } else if error._code == NSURLErrorNotConnectedToInternet || error._code == NSURLErrorCannotConnectToHost {
          // No Internet Connection
      
        }
        break
      }
    }
  }
}
