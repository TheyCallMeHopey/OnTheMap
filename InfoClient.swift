//
//  InfoClient.swift
//  On The Map
//
//  Created by Hope on 4/15/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import MapKit

class InfoClient : NSObject
{
    //TODO: May or may not need this later - just put it in as a reminder
    //var loggedIn = false
    
    var session: NSURLSession

    var userID: String? = nil
    var password: String? = nil
    var accountKey: String? = nil
    var sessionID: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = "city"
    var mediaURL: String? = "url"
    var userLat: Double? = 00.00
    var userLong: Double? = 00.00
    
    var currentLocation: CLLocation? = CLLocation(latitude: 00.00, longitude: 00.00)
    var userLocation: StudentLocation? = nil
    
    var students:[StudentLocation] = [StudentLocation]()

    //To center the map after the location has been found
    var pinData:PinData?
    
    override init()
    {
        session = NSURLSession.sharedSession()
        super.init()
    }

    //Handle JSON response - GET method
    func taskForGETMethod(udacity: Bool, baseURL: String, method: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void ) -> NSURLSessionDataTask
    {
        //Create request from URL
        let urlString = baseURL + method + parameters
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        //If request values are used in this request, add them to dictionary
        if !requestValues.isEmpty
        {
            for dict in requestValues
            {
                request.addValue(dict["value"]!, forHTTPHeaderField: dict["field"]!)
            }
        }
        
        //Pass response data to JSON parser
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler:
        {
            (data, response, downloadError) -> Void in

            if let error = downloadError
            {
                let newError = InfoClient.errorForData(data, response: response, error: error)
                
                completionHandler(result: nil, error: newError)
            }
            else
            {
                var newData = data
                
                //If udacity Bool is true, get a set of the data for Udacity requirements
                if udacity
                {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                }
                
                // Send data to JSON parser
                InfoClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        })
        
        task.resume()
        
        return task
    }
}

//Handle JSON response - POST method
func taskForPOSTMethod(udacity: Bool, baseURL: String, method: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
{
    var jsonError: NSError? = nil
    
    //Create request from URL
    let urlString = baseURL + method
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(URL: url)
    
    request.HTTPMethod = "POST"
    
    //If request values are used in this request, add them to dictionary
    for dict in requestValues
    {
        request.addValue(dict["value"]!, forHTTPHeaderField: dict["field"]!)
    }
    
    //Set HTTPBody of request
    request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
    
    //Pass response data to JSON parser
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler:
    {
        (data, response, downloadError) -> Void in
        
        if let error = downloadError
        {
            let newError = InfoClient.errorForData(data, response: response, error: error)
            
            completionHandler(result: nil, error: newError)
        }
        else
        {
            var newData = data
            
            //If udacity Bool is true, get a set of the data for Udacity requirements
            if udacity
            {
                //Get subset of data
                newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            }
            
            //Send data to JSON parser
            InfoClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
    })
    
    task.resume()
    
    return task
}

//Handle JSON response - PUT method
func taskForPUTMethod(udacity: Bool, baseURL: String, method: String, fileName: String, parameters: String, requestValues: [[String:String]], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask
{
    var jsonError: NSError? = nil
    
    //Create request from URL
    let urlString = baseURL + method + fileName
    let url = NSURL(string: urlString)!
    let request = NSMutableURLRequest(URL: url)
    
    request.HTTPMethod = "PUT"
    
    //If request values are used in this request, add them to dictionary
    for dict in requestValues
    {
        request.addValue(dict["value"]!, forHTTPHeaderField: dict["field"]!)
    }
    
    //Set HTTPBody of request
    request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
    
    //Pass response data to JSON parser
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request, completionHandler:
    {
        (data, response, downloadError) -> Void in
        
        if let error = downloadError
        {
            let newError = InfoClient.errorForData(data, response: response, error: error)
            
            completionHandler(result: nil, error: newError)
        }
        else
        {
            var newData = data
            
            //If udacity Bool is true, get a set of the data for Udacity requirements
            if udacity
            {
                //Get subset of data
                newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            }
            
            // Send data to JSON parser
            InfoClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
        }
    })
    
    task.resume()
    
    return task
}

//Parse JSON in NSData format
public func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void)
{
    var parsingError: NSError? = nil
    let parsedResult: AnyObject?
    
    do
    {
        parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
    }
    catch let error as NSError
    {
        parsingError = error
        parsedResult = nil
    }
    
    if let error = parsingError
    {
        NSLog("Error: \(parsingError)");
        
        completionHandler(result: nil, error: error)
    }
    else
    {
        completionHandler(result: parsedResult, error: nil)
    }
}

//Replace variable with a string value
public func substituteKeyInMethod(method: String, key: String, value: String) -> String?
{
    if method.rangeOfString("\(key)") != nil
    {
        return method.stringByReplacingOccurrencesOfString("\(key)", withString: value)
    }
    else
    {
        return nil
    }
}

//Error messages
public func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError
{
    //JSON data error
    if let parsedResult = (try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)) as? [String:AnyObject]
    {
        //Make readable
        if let errorMessage = parsedResult[JSONResponseKeys.Message] as? String
        {
            let errorCode = parsedResult[JSONResponseKeys.Code] as? Int
            let userInfo = [NSLocalizedDescriptionKey : errorMessage]
            
            return NSError(domain: "Flickr Error", code: errorCode!, userInfo: userInfo)
        }
    }
    
    return error
}

//Escaping values in parameters
public func escapedParameters(parameters: [String:AnyObject]) -> String
{
    var urlVars = [String]()
    
    for (key, value) in parameters
    {
        let stringValue = "\(value)"
        
        let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        urlVars += [key + "=" + "\(escapedValue!)"]
    }
    
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
}

func sharedInstance() -> InfoClient
{
    struct Singleton
    {
        static var sharedInstance = InfoClient()
    }
    
    return Singleton.sharedInstance
}



public func createUserLocation() -> NSDictionary
{
    var userLocationDictionary: [String:AnyObject]
    userLocationDictionary =
    [
        "uniqueKey" : InfoClient.sharedInstance().accountKey!,
        "firstName" : InfoClient.sharedInstance().firstName!,
        "lastName" : InfoClient.sharedInstance().lastName!,
        "mapString" : InfoClient.sharedInstance().mapString!,
        "mediaURL" : InfoClient.sharedInstance().mediaURL!,
        "latitude" : InfoClient.sharedInstance().userLat!,
        "longitude" : InfoClient.sharedInstance().userLong!
    ]
    
    return userLocationDictionary
}














