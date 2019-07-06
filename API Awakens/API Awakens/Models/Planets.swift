//
//  Planets.swift
//  API Awakens
//
//  Created by Tom Bastable on 01/07/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

class Planet: SWAPIObject {
    
    let name: String
    let url: String

    
    //associatedVehicles
    
    init(name: String, url: String) {
        
        self.name = name
        self.url = url
    }
    
    required convenience init?(json: [String: Any]) {
        
        struct Key {
            
            static let planetName = "name"
            static let planetUrl = "url"
            
        }
        
        guard let planetName = json[Key.planetName] as? String,
        let planetUrl = json[Key.planetUrl] as? String
            else {
                print("bum")
                return nil
        }
        
        self.init(name: planetName, url: planetUrl)
    }
}
