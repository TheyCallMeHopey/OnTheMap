//
//  InfoConstants.swift
//  On The Map
//
//  Created by Hope on 4/15/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

extension InfoClient
{
    struct BaseURLs
    {
        let baseURLSecureString = "https://udacity.com/api/"   

        static let UdacityBaseURLSecure: String = "https://www.udacity.com/api/"
        static let ParseBaseURLSecure: String = "https://parse.udacity.com/parse/classes/"
    }
    
    struct Methods
    {
        static let UsersUserID = "users"
        static let Session = "session"
        static let StudentLocation = "StudentLocation"
    }

    struct RequestKeys
    {
        static let Value = "value"
        static let ParseApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RESTAPIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        static let ApplicationJSON = "application/json"
        static let Field = "field"
        static let ParseAppIDField = "X-Parse-Application-Id"
        static let RESTAPIField = "X-Parse-REST-API-Key"
        static let Accept = "Accept"
        static let ContentType = "Content-Type"
    }
    
    struct URLKeys
    {
        static let AuthenticationDictionary = "{\"udacity\":{\"username\":\"uid\",\"password\": \"pwd\"}}"
        static let UpdateLocationDictionary = "{\"uniqueKey\": \"uKey\", \"firstName\": \"fName\", \"lastName\": \"lName\",\"mapString\": \"map\", \"mediaURL\": \"media\",\"latitude\": 37.322998, \"longitude\": -122.032182}"
        
        static let QueryStudentLocation = "?where=%7B%22uniqueKey%22%3A%22key%22%7D"
        
        static let UID = "uid"
        static let PWD = "pwd"
        static let Key = "key"
    }

    struct JSONResponseKeys
    {
        static let Status = "status"
        static let Error = "error"
        
        static let Account = "account"
        static let Registered = "registered"
        static let AccountKey = "key"
        
        static let Session = "session"
        static let SessionID = "id"
        static let User = "user"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        
        static let UpdatedAt = "updatedAt"
        
        static let Results = "results"
    }
    
    struct StudentLocationKeys
    {
        static let ObjectID = "objectID"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }

}





