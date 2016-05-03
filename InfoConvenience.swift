//
//  InfoConvenience.swift
//  On The Map
//
//  Created by Hope on 4/15/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import UIKit

extension InfoClient
{
    //Authenticate log in data, then get user data
    func authenticateWithLogIn(hostViewController: UIViewController, completionHandler: (success: Bool, error: String?) -> Void)
    {
        //Get account key from Udacity
        self.getAccountKey()
        {
            (success, error) -> Void in
            if success
            {
                //Get user data
                self.getUserData()
                {
                    (success, error) -> Void in
                    if success
                    {
                        completionHandler(success: success, error: error)
                    }
                    else
                    {
                        completionHandler(success: success, error: error)
                    }
                }
            }
            else
            {
                completionHandler(success: success, error: error)
            }
        }
    }

    //Use log in data to get account key from Udacity
    func getAccountKey(completionHandler: (success: Bool, error: String?) -> Void)
    {
        var parameters = InfoClient.substituteKeyInMethod(InfoClient.URLKeys.AuthenticationDictionary, key: InfoClient.URLKeys.UID, value: userID!)
        
        //Replace variables in parameter with actual data
        parameters = InfoClient.substituteKeyInMethod(parameters!, key: InfoClient.URLKeys.PWD, value: self.password!)
        
        //Dictionary that holds values for request
        var requestValues = [[String:String]]()
        
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ApplicationJSON, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.Accept])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ApplicationJSON, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ContentType])
        
        taskForPOSTMethod(true, baseURL:BaseURLs.UdacityBaseURLSecure, method: InfoClient.Methods.Session, parameters: parameters!, requestValues: requestValues)
            {
                (JSONResult, error) -> Void in
            
                if let error = error
                {
                    completionHandler(success: false, error: "Log in failed - account key/session ID \(error.localizedDescription)")
                }
                else
                {
                    
                //Get parsed JSON info
                if let status = JSONResult[JSONResponseKeys.Status] as? NSNumber
                {
                    if let JSONError: AnyObject? = JSONResult[JSONResponseKeys.Error]
                    {
                        //Return error info as string
                        completionHandler(success: false, error: "Status: \(status), Error: \(JSONError!)")
                    }
                }
                else
                {
                    //Does account exist?
                    if let account = JSONResult.valueForKey(InfoClient.JSONResponseKeys.Account) as? NSDictionary
                    {
                        //Did receive account key?
                        if let theAccountKey = account[InfoClient.JSONResponseKeys.AccountKey] as? String
                        {
                            self.accountKey = theAccountKey
                            
                            if let session = JSONResult.valueForKey(InfoClient.JSONResponseKeys.Session) as? NSDictionary
                            {
                                //Is there a session id?
                                if let id = session[InfoClient.JSONResponseKeys.SessionID] as? String
                                {
                                    self.sessionID = id
                                    
                                    completionHandler(success: true, error: nil)
                                }
                                else
                                {
                                    let theError = "JSONResult did not have key: id."
                                   
                                    completionHandler(success: false, error: theError)
                                }
                            }
                            else
                            {
                                let theError = "JSONResult did not have key: session."
                                
                                completionHandler(success: false, error: theError)
                            }
                            
                        }
                        else
                        {
                            let theError = "JSONResult did not have key: key."
                            
                            completionHandler(success: false, error: theError)
                        }
                    }
                    else
                    {
                        let theError = "JSONResult did not have key: account."
                        
                        completionHandler(success: false, error: theError)
                    }
                }
            }
        }
    }
    
    //Use the sessionID to get user data
    func getUserData(completionHandler: (success: Bool, error: String?) -> Void)
    {
        taskForGETMethod(true, baseURL: BaseURLs.UdacityBaseURLSecure, method: Methods.UsersUserID, parameters: "/"+self.accountKey!, requestValues: [])
        {
            (JSONResult, error) -> Void in
            
            if let error = error
            {
                completionHandler(success: false, error: "Search failed - \(error.localizedDescription)")
            }
            else
            {
                //Set last and first name
                if let user = JSONResult.valueForKey(InfoClient.JSONResponseKeys.User) as? [String:AnyObject]
                {
                    InfoClient.sharedInstance().lastName = user[InfoClient.JSONResponseKeys.LastName] as? String
                    InfoClient.sharedInstance().firstName = user[InfoClient.JSONResponseKeys.FirstName] as? String
                    
                    completionHandler(success: true, error: nil)
                }
                else
                {
                    completionHandler(success: false, error: "No key called user.")
                }
            }
        }
    }
    
    //Search Udacity for student location details
    func searchStudentLocation(completionHandler: (success: Bool, error: String?) -> Void)
    {
        let parameters = InfoClient.substituteKeyInMethod(InfoClient.URLKeys.QueryStudentLocation, key: InfoClient.URLKeys.Key, value: accountKey!)
        
        //Dictionary to hold request values
        var requestValues = [[String:String]]()
        
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ParseApplicationID, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ParseAppIDField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.RESTAPIKey, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.RESTAPIField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ApplicationJSON, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ContentType])
        
        taskForGETMethod(false, baseURL:BaseURLs.ParseBaseURLSecure, method: InfoClient.Methods.StudentLocation, parameters: parameters!, requestValues: requestValues)
            {
                (JSONResult, error) -> Void in

                if let error = error
                {
                    completionHandler(success: false, error: "Search failed - location \(error.localizedDescription)")
                }
                else
                {

                    //Dictionary of results exists in parsed JSON data?
                    if let results = JSONResult.valueForKey(InfoClient.JSONResponseKeys.Results) as? [[String:AnyObject]]
                    {
                    //Is dictionary of results empty?
                    if results.count > 0
                    {
                        print("found")
                        self.userLocation = StudentLocation(dictionary: results[0])
                        
                        completionHandler(success: true, error: nil)
                    }
                    else
                    {
                        self.userLocation = StudentLocation(dictionary: InfoClient.createUserLocation())
                        
                        print ("less than zero")
                        let theError = "Result count is less than or equal to zero."
                        
                        completionHandler(success: true, error: theError)
                    }
                }
                else
                {
                    print("Not found")
                    let theError = "User's StudentLocation not found."
                    completionHandler(success: true, error: theError)
                }
            }
        }
    }

    //Get dictionaries for all student locations on Udacity
    func getStudentLocations(completionHandler: (success: Bool, error: String?) -> Void)
    {
        let parameters = "?limit=500"
        
        //Dictionary that holds request values
        var requestValues = [[String:String]]()
        
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ParseApplicationID, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ParseAppIDField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.RESTAPIKey, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.RESTAPIField])
        
        taskForGETMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: InfoClient.Methods.StudentLocation, parameters: parameters, requestValues: requestValues)
        {
            (JSONResult, error) -> Void in
            
            if let error = error
            {
                completionHandler(success: false, error: "Search failed - student locations \(error.localizedDescription)")
            }
            else
            {
                //Does dictionary of results exist in parsed JSON data?
                if let results = JSONResult.valueForKey(InfoClient.JSONResponseKeys.Results) as? [[String:AnyObject]]
                {
                    //Array of StudentLocation objects for the locations - from results dictionary
                    self.students = StudentLocation.studentLocationsFromResults(results)

                    completionHandler(success: true, error: nil)
                }
                else
                {
                    let theError = "JSON Error - student locations"
                    completionHandler(success: true, error: theError)
                }
            }
            
        }
    }

    //User location on Udacity
    func createUserLocation(completionHandler: (success: Bool, error: String?) -> Void)
    {
        //String for updating dictionary of location data for Udacity user
        let updateString = InfoClient.sharedInstance().userLocation!.buildUpdateString()
        
        //Dictionary that holds request values
        var requestValues = [[String:String]]()
        
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ParseApplicationID, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ParseAppIDField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.RESTAPIKey, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.RESTAPIField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ApplicationJSON, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ContentType])
        
        taskForPOSTMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: Methods.StudentLocation, parameters: updateString, requestValues: requestValues)
        {
            (JSONResult, error) -> Void in
            
            if let error = error
            {
                completionHandler(success: false, error: "POST failed - create locations \(error.localizedDescription)")
            }
            else
            {
                completionHandler(success: true, error: nil)
            }
        }
    }

    //Update the user's location on Udacity
    func updateUserLocation(completionHandler: (success: Bool, error: String?) -> Void)
    {
        //String for updating dictionary of location data for Udacity user
        let objectID = InfoClient.sharedInstance().userLocation!.objectID
        let updateString = InfoClient.sharedInstance().userLocation!.buildUpdateString()

        //Dictionary that holds request values
        var requestValues = [[String:String]]()
        
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ParseApplicationID, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ParseAppIDField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.RESTAPIKey, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.RESTAPIField])
        requestValues.append([InfoClient.RequestKeys.Value : InfoClient.RequestKeys.ApplicationJSON, InfoClient.RequestKeys.Field : InfoClient.RequestKeys.ContentType])
        
        taskForPUTMethod(false, baseURL: BaseURLs.ParseBaseURLSecure, method: Methods.StudentLocation, fileName: "/"+objectID, parameters: updateString, requestValues: requestValues)
        {
            (JSONResult, error) -> Void in

            if let error = error
            {
                completionHandler(success: false, error: "PUT failed - update locations \(error.localizedDescription)")
            }
            else
            {
                completionHandler(success: true, error: nil)
            }
        }
    }
}






