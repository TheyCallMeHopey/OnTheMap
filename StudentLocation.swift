//
//  StudentLocation.swift
//  On The Map
//
//  Created by Hope on 4/15/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import UIKit

struct StudentLocation 
{
    var objectID = ""
    
    var uniqueKey = ""
    var firstName = ""
    var lastName = ""
    
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    
    var studentDictionary: [String:AnyObject]
    
    init(dictionary: [String:AnyObject])
    {
        if let object = dictionary["objectId"] as? String { objectID = object }
        
        if let unique = dictionary["uniqueKey"] as? String { uniqueKey = unique }
        if let first = dictionary["firstName"] as? String { firstName = first }
        if let last = dictionary["lastName"] as? String { lastName = last }
        
        if let map = dictionary["mapString"] as? String { mapString = map }
        if let media = dictionary["mediaURL"] as? String { mediaURL = media }
        if let lat = dictionary["latitude"] as? Double { latitude = lat }
        if let long = dictionary["longitude"] as? Double { longitude = long }
        
        studentDictionary =
        [
            "uniqueKey" : uniqueKey,
            "firstName" : firstName,
            "lastName" : lastName,
            "mapString" : mapString,
            "mediaURL" : mediaURL,
            "latitude" : latitude,
            "longitude" : longitude
        ]
    }
    
    //Array of StudentLocation objects from received information
    static func studentLocationsFromResults(results: [[String:AnyObject]]) -> [StudentLocation]
    {
        var studentLocations = [StudentLocation]()
        
        for result in results
        {
            studentLocations.append(StudentLocation(dictionary: result))
        }
        
        return studentLocations
    }
    
    //String values for JSON updated dictionary
    func buildUpdateString() -> String
    {
        var updateString: String
        
        updateString = "{\"uniqueKey\": \"\(uniqueKey)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\":\(longitude)}"
        
        return updateString
    }
}






