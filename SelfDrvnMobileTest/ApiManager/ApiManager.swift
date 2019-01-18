//
//  ApiManager.swift
//  PracticalTestPlanets
//
//  Created by Mukesh Verma on 20/12/18.
//  Copyright © 2018 Mukesh Verma. All rights reserved.
//

import UIKit

// MARK: Enums
//Error Handling Enums

enum ApiErrors: Error {
    case dataNotFound
    case invalidResponse
    case unsuppotedURL
}

class ApiManager: NSObject {

    // MARK: Get Request
    
    func makeGetRestApiRequest(_ apiURL: String,  _ completionHandler:@escaping ((BookSwagger?, ApiErrors?) -> (Void))) {
        
        // Set up the URL request
        guard let url = URL(string: apiURL) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on \(apiURL)")
                print(error!)
                completionHandler(nil,ApiErrors.unsuppotedURL)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                completionHandler(nil,ApiErrors.dataNotFound)
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(BookSwagger.self, from: responseData)
               
                completionHandler(responseModel,nil)
             
            } catch  {
                 completionHandler(nil,ApiErrors.invalidResponse)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
}
