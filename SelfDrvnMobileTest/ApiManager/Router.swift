//
//  Router.swift

//
//  Created by Verma Mukesh on 21/07/17.
//  Copyright © 2017 Verma Mukesh All rights reserved.
//

import Foundation
import Alamofire

struct ParamKeys {
  static let query: String = "query"
  static let body: String = "body"
  static let json: String = "json"
}

// API version keys
enum API_VERSION: String {
  case NO_VERSION = ""
  case V_0 = "v0"
  case V_1 = "v1"
  case V_2 = "v2"
  case V_3 = "v3"
}

public typealias JSONDictionary = [String: Any]
public typealias JSONArray = [JSONDictionary]
typealias APIParams = [String : Any]?
typealias RequestBody = [String : Any]
typealias HTTPHeaders = [String : String]?

protocol HTTPRequest {
  var baseUrl: String { get }
  var method: Alamofire.HTTPMethod { get }
  var headers: HTTPHeaders { get }
  var version: API_VERSION { get }
  var path: String { get }
  var parameters: APIParams { get }
  var encoding: Alamofire.ParameterEncoding? { get }
}

class Router : URLRequestConvertible, HTTPRequest {
  
  init() {}
  
  fileprivate var headersWithRenewedToken: [String : String]?
  
  var baseUrl: String {
    let baseUrl = "https://www.booknomads.com/api" // Ideally it should be fetched from config file
    return baseUrl
  }
  
  var method: Alamofire.HTTPMethod {
    fatalError("[\(#function))] Must be overridden in subclass")
  }
  
  var headers: HTTPHeaders {
    if let value = headersWithRenewedToken {
      return value
    } else {
      return self.headers
    }
  }
  
  var version: API_VERSION {
    fatalError("[\(#function))] Must be overridden in subclass")
  }
  
  var path: String {
    fatalError("[\(#function))] Must be overridden in subclass")
  }
  
  var parameters: APIParams {
    fatalError("[\(#function))] Must be overridden in subclass")
  }
  
  var encoding: Alamofire.ParameterEncoding? {
    return CompositeEncoding()
  }
  
  var shouldRetry: Bool {
    return false
  }
  
  func asURLRequest() throws -> URLRequest {
    let baseURL = URL(string: baseUrl);
    var mutableURLRequest = URLRequest(url: baseURL!)
    if version.rawValue != "" {
      mutableURLRequest = URLRequest(url: mutableURLRequest.url!.appendingPathComponent(version.rawValue))
    }
    mutableURLRequest = URLRequest(url: mutableURLRequest.url!.appendingPathComponent(path))
    
    mutableURLRequest.httpMethod = method.rawValue
    mutableURLRequest.allHTTPHeaderFields = headers
    // If HTTP method is other than GET then add Accept header
    if self.method != .get {
      mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    }
    if let encoding = encoding {
      return try encoding.encode(mutableURLRequest, with: parameters)
    }
    return mutableURLRequest as URLRequest
  }
}

// MARK:- Custom Encoding
struct CompositeEncoding: ParameterEncoding {
  public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
    guard let parameters = parameters else {
      return try urlRequest.asURLRequest()
    }
    
    var queryRequest = try urlRequest.asURLRequest()
    if let query = parameters[ParamKeys.query] {
      let queryParameters = (query as! Parameters)
      queryRequest = try URLEncoding(destination: .queryString).encode(urlRequest, with: queryParameters)
    }
    
    if let body = parameters[ParamKeys.body] {
      let bodyParameters = (body as! Parameters)
      var bodyRequest = try URLEncoding().encode(urlRequest, with: bodyParameters)
      
      bodyRequest.url = queryRequest.url
      return bodyRequest
    }
    else if let body = parameters[ParamKeys.json] {
      let bodyParameters = (body as! Parameters)
      var bodyRequest = try JSONEncoding().encode(urlRequest, with: bodyParameters)
      
      bodyRequest.url = queryRequest.url
      return bodyRequest
    }
    else {
      return queryRequest
    }
  }
}

func +=<U,T>( lhs: inout [U:T], rhs: [U:T]) {
  for (key, value) in rhs {
    lhs[key] = value
  }
}
