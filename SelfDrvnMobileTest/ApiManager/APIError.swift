//
//  HTError.swift

//
//  Created by Verma Mukesh on 28/07/17.
//  Copyright © 2017 Verma Mukesh All rights reserved.
//

import Foundation

public struct APIErrorParser {
  let errorType: String
  let errorDescritpion: String
  let statusCode: HttpStatusCode!
  var apiError: APIError
  
  init(value: [String: String], statusCode: HttpStatusCode) {
    self.errorType = value["type"]!
    self.errorDescritpion = value["error"]!
    self.statusCode = statusCode
    self.apiError = APIError.unknownError
    
    // Update HTError
    self.apiError = self.getAPIError(errorType: APIErrorType.init(rawValue: self.errorType)!)
  }
}

extension APIErrorParser {
  func getAPIError(errorType: APIErrorType) -> APIError {
    switch errorType {
    // HTTP 400
    
    // HTTP 401
    
    // HTTP 403
    
    // HTTP 404
    
    // HTTP 403
    
    // HTTP 500
    
    case .IllegalArgumentException: return .serverRequestFailed(reason: .IllegalArgumentException(error: self))
    default: return .unknownError
      
    }
  }
}

public enum APIErrorType: String {
  // HTTP 400
  
  // 401
  
  // 403
  
  // 404
  
  // 409
  
  // 500
  case IllegalArgumentException              = "IllegalArgumentException"
  
  // Unknown Error
  case UnknownError                         = "Unknown Error Occured"
}

public enum APIError: Error {
  // ** // ** // ** // ** // ** // HTTP 400 // ** // ** // ** // ** // ** //
  
  // ** // ** // ** // ** // ** // HTTP 401 // ** // ** // ** // ** // ** //
  
  // ** // ** // ** // ** // ** // HTTP 403 // ** // ** // ** // ** // ** //
  
  // ** // ** // ** // ** // ** // HTTP 404 // ** // ** // ** // ** // ** //
  
  // ** // ** // ** // ** // ** // HTTP 409 // ** // ** // ** // ** // ** //
  
  // ** // ** // ** // ** // ** // HTTP 500 // ** // ** // ** // ** // ** //
  public enum ServerRequestFailureReason {
    case IllegalArgumentException(error: Any) // 4001 - IllegalArgumentException
  }
  
  case serverRequestFailed(reason: ServerRequestFailureReason)
  case unknownError
}

// ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** //
// MARK: - Error Booleans
extension APIError {
  public var isServerRequestFailedError: Bool {
    if case .serverRequestFailed = self { return true }
    return false
  }
}

// ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // Extension: Convenience Properties // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** //
// MARK: - Extension: Convenience Properties
extension APIError {
  public var type: String? {
    switch self {
    case .serverRequestFailed(let reason):
      return reason.type
    case .unknownError:
      return "Unknown"
    }
  }
}

// ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // Extension: LocalizedError // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** //
// Mark: - Extension: LocalizedError
extension APIError: LocalizedError {
  public var errorMessage: String? {
    switch self {
    case .serverRequestFailed(let reason):
      return reason.localizedErrorMessage
    case .unknownError:
      return "We've encountered an unknown error. If problem persist then send us feedback."
    }
  }
}

// ** // ** // ** // ** // ** // ** // ** // ** // ** // ** // Extension: ServerRequestFailureReason // ** // ** // ** // ** // ** // ** // ** // ** // ** // ** //
// Mark: - Extension: ServerRequestFailureReason
extension APIError.ServerRequestFailureReason {
  var localizedErrorMessage: String {
    switch self {
    case .IllegalArgumentException(let error as APIErrorParser):
      return error.errorDescritpion
    default: return "Unknown Error"
    }
  }
}

extension APIError.ServerRequestFailureReason {
  var type: String? {
    switch self {
    case .IllegalArgumentException(let error as APIErrorParser):
      return error.errorType
    default: return nil
    }
  }
}
