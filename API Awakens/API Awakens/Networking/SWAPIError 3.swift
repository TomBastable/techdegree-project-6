//
//  SWAPIError.swift
//  API Awakens
//
//  Created by Tom Bastable on 26/06/2019.
//  Copyright © 2019 Tom Bastable. All rights reserved.
//

import Foundation

enum SWAPIError: Error{
    
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure(message: String)
    case downcastError
    case resultsRetrievalError
    case heightConversionError
    case lengthConversionError
    
}
