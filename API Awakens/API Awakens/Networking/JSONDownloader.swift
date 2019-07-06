//
//  JSONDownloader.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

class JSONDownloader {
    let session: URLSession
    
    init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    
    convenience init() {
        self.init(configuration: .default)
    }
    
    typealias JSON = [String: AnyObject]
    typealias JSONTaskCompletionHandler = (JSON?,retrievalStatus?, SWAPIError?) -> Void
    
    func jsonTask(with request: URLRequest, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTask {
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, nil, .requestFailed)
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let data = data {
                    
                    let decoder = JSONDecoder()
                    let stats = try! decoder.decode(retrievalStatus.self, from: data)
                    
                    do {
                        
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
                        completion(json, stats, nil)
                        
                    } catch {
                        completion(nil, nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, nil, .invalidData)
                }
            } else {
                completion(nil, nil, .responseUnsuccessful)
            }
            
        }
        
        return task
    }
}
