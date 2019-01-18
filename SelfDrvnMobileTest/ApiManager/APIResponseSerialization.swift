//
//  APIResponseSerialization.swift

//
//  Created by Verma Mukesh on 02/08/17.
//  Copyright © 2017 Verma Mukesh All rights reserved.
//

import Foundation
import Alamofire

/// A set of HTTP response status code that do not contain response data.
private let emptyDataStatusCodes: Set<Int> = [204, 205]

// The type in which all data response serializers must conform to in order to serialize a response.
public protocol HTDataResponseSerializerProtocol {
  /// The type of serialized object to be created by this `DataResponseSerializerType`.
  associatedtype HTSerializedResponseObject
  
  /// A closure used by response handlers that takes a request, response, data and error and returns a result.
  var serializeResponse: (DataResponse<Any>?) -> APIResult<HTSerializedResponseObject> { get }
}

public struct APIResponseSerializer<Value>: HTDataResponseSerializerProtocol {
  /// The type of serialized object to be created by this `DataResponseSerializerType`.
  typealias APISerializedObject = Value
  
  /// A closure used by response handlers that takes a request, response, data and error and returns a result.
  public var serializeResponse: (DataResponse<Any>?) -> APIResult<Value>
  
  /// Initializes the `ResponseSerializer` instance with the given serialize response closure.
  ///
  /// - parameter serializeResponse: The closure used to serialize the response.
  ///
  /// - returns: The new generic response serializer instance.
  public init(serializeResponse: @escaping (DataResponse<Any>?) -> APIResult<Value>) {
    self.serializeResponse = serializeResponse
  }
}

// MARK: - Default

extension APIResponse {
  
  /// Adds a handler to be called once the request has finished.
  ///
  /// - parameter responseSerializer: The response serializer responsible for serializing the request, response,
  ///                                 and data.
  /// - parameter completionHandler:  The code to be executed once the request has finished.
  ///
  /// - returns: The request.
  @discardableResult
  public func response<T: HTDataResponseSerializerProtocol>(
    responseSerializer: T,
    completionHandler: @escaping (HTDataResponse<T.HTSerializedResponseObject>) -> Void)
    -> Self
  {
    let result = responseSerializer.serializeResponse(
      self.dataResponse
    )
    
    let dataResponse = HTDataResponse<T.HTSerializedResponseObject>(
      dataResponse: self.dataResponse!,
      result: result
    )
    completionHandler(dataResponse)
    
    return self
  }
}

// MARK: - JSON

extension APIResponse {
  /// Returns a object contained in a result type constructed from the response data
  ///
  /// - parameter response: The serialized response from the server.
  ///
  /// - returns: The result data type.
  public static func serializeAPIResponse(
    response: DataResponse<Any>?)
    -> APIResult<Any>
  {
    
    guard response!.error == nil else { return .failure(response!.error!) }
    
    if let response = response, emptyDataStatusCodes.contains(response.response!.statusCode) { return .success(NSNull()) }
    
    // Check for HTTP Status 
    // Check api response, if error generate HTError, create APIError instance using api response
    
    let result = response!.result.value
    let JSON = result as! NSDictionary
    
    let statusCode = response!.response!.statusCode;
    guard 200 ... 299 ~= statusCode else {
      let apiErrorParser = APIErrorParser.init(value: JSON as! [String : String], statusCode: HttpStatusCode(rawValue: statusCode)!)
      return .failure(apiErrorParser.apiError)
    }
    
    
    return .success(result!)
  }
}

extension APIResponse {
  /// Creates a response serializer that returns serialized http response object and local serialized object result type constructed from the response data
  ///
  ///
  /// - returns: A object response serializer.
  public static func jsonResponseSerializer()
    -> APIResponseSerializer<Any>
  {
    return APIResponseSerializer { dataResponse in
      return APIResponse.serializeAPIResponse(response: dataResponse!)
    }
  }
  
  /// Adds a handler to be called once the request has finished.
  ///
  /// - parameter completionHandler: A closure to be executed once the request has finished.
  ///
  /// - returns: The request.
  @discardableResult
  public func responseAPI(
    completionHandler: @escaping (HTDataResponse<Any>) -> Void)
    -> Self
  {
    return response(
      responseSerializer: APIResponse.jsonResponseSerializer(),
      completionHandler: completionHandler
    )
  }
}
