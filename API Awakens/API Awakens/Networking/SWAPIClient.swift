//
//  SWAPIClient.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

class SWAPIClient {
    
    let downloader = JSONDownloader()
    
    func getCharacters(completion: @escaping ([Character], SWAPIError?) -> Void) {
        
        let endpoint = SWAPI.characters
            
            self.retrieveAllPages(withNextUrl: endpoint.request, arrayOfSwapiObjects: []) { char, error in
                
                completion(char, error)
                
            }
    }
    
    func getVehicles(completion: @escaping ([Vehicles], SWAPIError?) -> Void) {
        
        let endpoint = SWAPI.vehicles
        
        self.retrieveAllPages(withNextUrl: endpoint.request, arrayOfSwapiObjects: []) { vehicle, error in
            
            completion(vehicle, error)
            
        }
        
    }
    
    func getStarships(completion: @escaping ([Starships], SWAPIError?) -> Void) {
        
        let endpoint = SWAPI.starships
        self.retrieveAllPages(withNextUrl: endpoint.request, arrayOfSwapiObjects: []) { starship, error in
            
            completion(starship, error)
            
        }
        
    }
    
    func getPlanets(completion: @escaping ([Planet], SWAPIError?) -> Void) {
        
        let endpoint = SWAPI.planets
        self.retrieveAllPages(withNextUrl: endpoint.request, arrayOfSwapiObjects: []) { planet, error in
            
            completion(planet, error)
        }
        
    }
    
    func getCharacterMetaEndpoints(completion: @escaping ([Planet], [Vehicles], [Starships], SWAPIError?) -> Void){
        
        getVehicles { (vehicles, error) in
            
            self.getStarships(completion: { (starships, error) in
                
                self.getPlanets(completion: { (planets, error) in
                    
                    completion(planets, vehicles, starships, error)
                    
                })
            })
            
        }
        
    }
    
    typealias Results = [[String: Any]]
    
    func performRequest(with endpoint: URLRequest, completion: @escaping (Results?, retrievalStatus?, SWAPIError?) -> Void) {
        
        let task = downloader.jsonTask(with: endpoint) { json, status, error in
            DispatchQueue.main.async {
                guard let json = json else {
                   
                    completion(nil, nil, error)
                    return
                }
                
                guard let results = json["results"] as? [[String: Any]] else {
                   
                    completion(nil, nil, .jsonParsingFailure(message: "JSON data does not contain results"))
                    return
                }
                completion(results, status, nil)
            }
        }
        
        task.resume()
        
    }
    
    //MARK: Retrieve Remaining Pages **Method is Polymorphic, all SWAPIObjects can use this**
    
    func retrieveAllPages<T: SWAPIObject>(withNextUrl url: URLRequest, arrayOfSwapiObjects:[T], completion: @escaping ([T], SWAPIError?) -> Void){
        //Perform the request
        performRequest(with: url) { results, status, error in
            //Unwrap the results
            guard let results = results else {
                
                completion([], .resultsRetrievalError)
                
                return
            }
            //initialise a variable to store the newly fetched data, flatten it.
            var combinedArray = results.compactMap { T(json: $0) }
            //add the initial array with the new array
            combinedArray = arrayOfSwapiObjects + combinedArray
            //check to see if there is another page of results after this
            guard let isNext = status?.next else{
                
                //if there isn't, below code will be executed
                //
                //
                //Check to see if the generic type is Character, if so add character metadata
                if T.self == Character.self{
                    
                    //safely downcast generic to Character, despite being able to force downcast after the previous check
                    guard var characters: [Character] = combinedArray as? [Character] else{
                        completion([], .downcastError)
                        return
                    }
                    //Call the character meta endpoints in one function
                    self.getCharacterMetaEndpoints(completion: { (planets, vehicles, starships, error) in
                        
                        //swap endpoint url's for names (inout function so no need to assign traditionally)
                        self.swapUrlsForNames(characters: &characters, vehicles: vehicles, starships: starships, planets: planets)
                        //cast to generic type for required return type
                        guard let combinedArray: [T] = characters as? [T] else{
                            completion([], .downcastError)
                            return
                        }
                        //completion with exchanged names
                        completion(combinedArray, error)
                        
                    })
                    
                }else{
                    
                //is not character, so return without the need for additional meta data.
                completion(combinedArray, error)
                    
                }
                return
            }
           
            
            //At this point the function will only continue executing if there is another page of results - repeat until completion.
            //wrap the url string as a urlRequest
            let urlReq = URLRequest(url: URL(string: isNext)!)
            
            self.retrieveAllPages(withNextUrl: urlReq, arrayOfSwapiObjects: combinedArray) { char, error in
                
                if error != nil {
                completion([], error)
                }else{
                completion(char, error)
                }
                
            }
            
        }
        
    }
    
    func swapUrlsForNames(characters: inout [Character], vehicles: [Vehicles], starships: [Starships], planets: [Planet]) {
        
        //loop through each character
        for character in characters {
            //check for unknown planet name
            if character.home != "unknown"{
                //loop through the planets
                for planet in planets{
                    //if the endpoint url is equal to the planet url, replace the url with the correct name
                    if character.home == planet.url{
                        character.home = planet.name
                    }
                    
                }
            }
            //create temporary array to fill (Saves finding the index of each array and replacing - mimic the array and replace whole array instead)
            var tempArray: [String] = []
            //loop through associated vehicles
            for vehic in character.associatedVehicles{
                //if the vehicle url matches the url of the vehicle, add the vehicle name to the mimic array
                for vehicle in vehicles{
                    if vehic == vehicle.url{
                        tempArray.append(vehicle.name)
                    }
                }
            }
            //assign mimic array to character
            character.associatedVehicles = tempArray
            
            //empty mimic array ready for starships
            tempArray = []
            
            //loop through starships
            for star in character.associatedStarships{
                //if the starships url matches, add the starship name to the mimic array
                for starship in starships{
                    if star == starship.url{
                        tempArray.append(starship.name)
                    }
                }
            }
            //assign mimic array to starships
            character.associatedStarships = tempArray
            
            //no need to return as the function is an inout function
        }
        
    }
}
