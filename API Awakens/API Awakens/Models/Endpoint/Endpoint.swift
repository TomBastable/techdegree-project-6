//
//  Endpoint.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

protocol Endpoint {
    
    var base: String { get }
    var path: String { get }
    
}

extension Endpoint {
    
    var urlComponents: URLComponents {
        
        var components = URLComponents(string: base)!
        components.path = path
        
        return components
    }
    
    var request: URLRequest {
        
        let url = urlComponents.url!
        return URLRequest(url: url)
        
    }
    
}

enum SWAPI {
    
    case characters
    case vehicles
    case starships
    case planets
    
}

class nextEndpoint: Endpoint{
    
    var base: String
    var path: String
    
    init(base: String) {
        self.base = ""
        self.path = base
    }
}

extension SWAPI: Endpoint {
    
    var base: String {
        return "https://swapi.co"
    }
    
    var path: String {
        
        switch self {
            
        case .characters: return "/api/people"
        case .vehicles: return "/api/vehicles"
        case .starships: return "/api/starships"
        case .planets: return "/api/planets"
            
        }
        
    }
    
}
