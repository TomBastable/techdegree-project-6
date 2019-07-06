//
//  Characters.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

protocol SWAPIObject {
    init?(json: [String: Any])
}

class Character:SWAPIObject {
    
    let name: String
    let birthDate: String
    var home: String
    let height: String
    let eyes: String
    let hair: String
    let url: String
    var associatedVehicles: [String]
    var associatedStarships: [String]
    
    //associatedVehicles
    
    init(name: String, birthDate: String, home: String, height: String, eyes: String, hair: String, url: String, associatedVehicles: [String], associatedStarships: [String]) {
        
        self.name = name
        self.birthDate = birthDate
        self.home = home
        self.height = height
        self.eyes = eyes
        self.hair = hair
        self.url = url
        self.associatedVehicles = associatedVehicles
        self.associatedStarships = associatedStarships
    }
    
    required convenience init?(json: [String: Any]) {
        
        struct Key {
            
            static let characterName = "name"
            static let characterHome = "homeworld"
            static let characterHeight = "height"
            static let characterEyes = "eye_color"
            static let characterHair = "hair_color"
            static let characterUrl = "url"
            static let characterBirthdate = "birth_year"
            static let characterVehicles = "vehicles"
            static let characterStarships = "starships"
            
        }
        
        guard let characterName = json[Key.characterName] as? String,
            let characterHome = json[Key.characterHome] as? String,
            let characterHeight = json[Key.characterHeight] as? String,
            let characterEyes = json[Key.characterEyes] as? String,
            let characterHair = json[Key.characterHair] as? String,
            let characterUrl = json[Key.characterUrl] as? String,
            let characterBirthdate = json[Key.characterBirthdate] as? String,
            let characterVehicles = json[Key.characterVehicles] as? [String],
            let characterStarships = json[Key.characterStarships] as? [String]
            else {
                print("bum")
                return nil
        }
        
        self.init(name: characterName, birthDate: characterBirthdate, home: characterHome, height: characterHeight, eyes: characterEyes, hair: characterHair, url: characterUrl, associatedVehicles: characterVehicles, associatedStarships: characterStarships)
    }
}

