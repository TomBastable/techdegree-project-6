//
//  Vehicles.swift
//  API Awakens
//
//  Created by Tom Bastable on 29/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

class Vehicles: SWAPIObject {
    
    let name: String
    let make: String
    let cost: String
    let vehicleClass: String
    let length: String
    let crew: String
    let url: String
    
    //associatedVehicles
    
    init(name: String, make: String, cost: String, vehicleClass: String, length: String, crew: String, url: String) {
        
        self.name = name
        self.make = make
        self.cost = cost
        self.vehicleClass = vehicleClass
        self.length = length
        self.crew = crew
        self.url = url
        
    }
    
    required convenience init?(json: [String: Any]) {
        
        struct Key {
            
            static let vehicleName = "name"
            static let vehicleMake = "manufacturer"
            static let vehicleCost = "cost_in_credits"
            static let vehicleClass = "vehicle_class"
            static let vehicleLength = "length"
            static let vehicleCrew = "crew"
            static let vehicleUrl = "url"
            
        }
        
        guard let vehicleName = json[Key.vehicleName] as? String,
            let vehicleMake = json[Key.vehicleMake] as? String,
            let vehicleCost = json[Key.vehicleCost] as? String,
            let vehicleClass = json[Key.vehicleClass] as? String,
            let vehicleLength = json[Key.vehicleLength] as? String,
            let vehicleCrew = json[Key.vehicleCrew] as? String,
            let vehicleUrl = json[Key.vehicleUrl] as? String
            else {
                return nil
        }
        
        self.init(name: vehicleName, make: vehicleMake, cost: vehicleCost, vehicleClass: vehicleClass, length: vehicleLength, crew: vehicleCrew, url: vehicleUrl)
    }
}
