//
//  BookRouter.swift
//  SelfDrvnMobileTest
//
//  Created by Verma Mukesh on 18/01/19.
//  Copyright © 2019 Verma Mukesh. All rights reserved.
//

import Foundation
import Alamofire

// Param which starts with "_" is URI parameter value and rest are query
// 1
enum BookEndpint {
  case Search(_isbn: String)
}

class BookRouter: Router {
  
  var endpoint: BookEndpint
  init(endpoint: BookEndpint) {
    self.endpoint = endpoint
  }
  
  override var method: HTTPMethod {
    switch endpoint {
    case .Search: return .get
    }
  }
  
  override var version: API_VERSION {
    switch endpoint {
    case .Search: return .V_0
    }
  }
  
  override var path: String {
    switch endpoint {
    case .Search(let _isbn): return "/isbn/\(_isbn)"
    }
  }
  
  override var headers: HTTPHeaders {
    return [:]
  }

  // We can utilize this to send query and body params
  override var parameters: APIParams {
//    var queryParams = [String: Any]()
//    var bodyParams = [String: Any]()
//
    return [:]
  }
}
