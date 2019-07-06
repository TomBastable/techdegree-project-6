//
//  Starships.swift
//  API Awakens
//
//  Created by Tom Bastable on 29/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

class Starships: SWAPIObject {
    
    let name: String
    let make: String
    let cost: String
    let starshipsClass: String
    let length: String
    let crew: String
    let url: String
    
    init(name: String, make: String, cost: String, starshipsClass: String, length: String, crew: String, url: String) {
        
        self.name = name
        self.make = make
        self.cost = cost
        self.starshipsClass = starshipsClass
        self.length = length
        self.crew = crew
        self.url = url
        
    }
    
    required convenience init?(json: [String: Any]) {
        
        struct Key {
            
            static let starshipsName = "name"
            static let starshipsMake = "manufacturer"
            static let starshipsCost = "cost_in_credits"
            static let starshipsClass = "starship_class"
            static let starshipsLength = "length"
            static let starshipsCrew = "crew"
            static let starshipsUrl = "url"
            
        }
        
        guard let starshipsName = json[Key.starshipsName] as? String,
            let starshipsMake = json[Key.starshipsMake] as? String,
            let starshipsCost = json[Key.starshipsCost] as? String,
            let starshipsClass = json[Key.starshipsClass] as? String,
            let starshipsLength = json[Key.starshipsLength] as? String,
            let starshipsCrew = json[Key.starshipsCrew] as? String,
            let starshipsUrl = json[Key.starshipsUrl] as? String
            else {
                
                return nil
        }
        
        
        
        self.init(name: starshipsName, make: starshipsMake, cost: starshipsCost, starshipsClass: starshipsClass, length: starshipsLength, crew: starshipsCrew, url: starshipsUrl)
    }
}
