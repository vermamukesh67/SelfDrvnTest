//
//  Response.swift
//  Harris Teeter
//
//  Created by Verma Mukesh on 02/08/17.
//  Copyright © 2017 Verma Mukesh All rights reserved.
//

import Foundation
import Alamofire

open class APIResponse {

  open var dataResponse: DataResponse<Any>?
  
  init(dataResponse: DataResponse<Any>?) {
    self.dataResponse = dataResponse
  }
}

/// Used to store all data associated with a serialized response of a data or upload request.
public struct HTDataResponse<Value> {
  
  // Serialized response returned from server or error if encountered
  // request - The URL request sent to the server.
  // response - The server's response to the URL request.
  // data - The data returned by the server.
  // result - The result of response serialization.
  // value - Returns the associated value of the result if it is a success, `nil` otherwise.
  // error - Returns the associated error value if the result if it is a failure, `nil` otherwise.
  public let dataResponse: DataResponse<Any>
  
  /// The result of response serialization.
  public let result: APIResult<Value>
  
  /// Returns the associated value of the result if it is a success, `nil` otherwise.
  public var value: Value? { return result.value }
  
  /// Returns the associated error value if the result if it is a failure, `nil` otherwise.
  public var error: Error? { return result.error }
  
  /// Creates a `DataResponse` instance with the specified parameters derived from response serialization.
  ///
  /// - parameter request:  The URL request sent to the server.
  /// - parameter response: The server's response to the URL request.
  /// - parameter data:     The data returned by the server.
  /// - parameter result:   The result of response serialization.
  ///
  /// - returns: The new `DataResponse` instance.
  public init(
    dataResponse: DataResponse<Any>,
    result: APIResult<Value>)
  {
    self.dataResponse = dataResponse
    self.result = result
  }
}

// MARK: -

extension HTDataResponse: CustomStringConvertible, CustomDebugStringConvertible {
  /// The textual representation used when written to an output stream, which includes whether the result was a
  /// success or failure.
  public var description: String {
    return result.debugDescription
  }
  
  /// The debug textual representation used when written to an output stream, which includes locally response serialization result.
  public var debugDescription: String {
    var output: [String] = []
    
    output.append("[Result]: \(result.debugDescription)")
    
    return output.joined(separator: "\n")
  }
}

// MARK: -

extension HTDataResponse {
  /// Evaluates the specified closure when the result of this `DataResponse` is a success, passing the unwrapped
  /// result value as a parameter.
  ///
  /// Use the `map` method with a closure that does not throw. For example:
  ///
  ///     let possibleData: DataResponse<Data> = ...
  ///     let possibleInt = possibleData.map { $0.count }
  ///
  /// - parameter transform: A closure that takes the success value of the instance's result.
  ///
  /// - returns: A `DataResponse` whose result wraps the value returned by the given closure. If this instance's
  ///            result is a failure, returns a response wrapping the same failure.
  public func map<T>(_ transform: (Value) -> T) -> HTDataResponse<T> {
    let response = HTDataResponse<T>(
      dataResponse: dataResponse,
      result: result.map(transform)
    )
    
    return response
  }
  
  /// Evaluates the given closure when the result of this `DataResponse` is a success, passing the unwrapped result
  /// value as a parameter.
  ///
  /// Use the `flatMap` method with a closure that may throw an error. For example:
  ///
  ///     let possibleData: DataResponse<Data> = ...
  ///     let possibleObject = possibleData.flatMap {
  ///         try JSONSerialization.jsonObject(with: $0)
  ///     }
  ///
  /// - parameter transform: A closure that takes the success value of the instance's result.
  ///
  /// - returns: A success or failure `DataResponse` depending on the result of the given closure. If this instance's
  ///            result is a failure, returns the same failure.
  public func flatMap<T>(_ transform: (Value) throws -> T) -> HTDataResponse<T> {
    let response = HTDataResponse<T>(
      dataResponse: dataResponse,
      result: result.flatMap(transform)
    )
    
    return response
  }
}

