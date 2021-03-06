//
//  MapViewController.swift
//  On The Map
//
//  Created by Hope on 4/21/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class MapViewController: UIViewController, MKMapViewDelegate
{
    var pinData = [PinData]()
    var students = [StudentLocation]()

    let regionRadius: CLLocationDistance = 5000000
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func logoutButton(sender: AnyObject)
    {
        InfoClient.sharedInstance().loggedIn = false
        
        self.dismissViewControllerAnimated(true, completion: nil)
        delete()
        
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func pinButton(sender: AnyObject)
    {
        findLocation()
    }
    
    @IBAction func refreshButton(sender: AnyObject)
    {
        getStudentLocations()
        
        print ("Refreshed")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        getStudentLocations()
        
        //TODO: test (new)
        if let pin = InfoClient.sharedInstance().pinData
        {
            self.mapView!.addAnnotation(pin)
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        centerMapLocation(InfoClient.sharedInstance().currentLocation!)
        
        //TODO: test (old)
//        if let pin = InfoClient.sharedInstance().pinData
//        {
//            self.mapView!.addAnnotation(pin)
//        }
    }
    
    //Allow the user to set/update their location
    func findLocation()
    {
        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        
        presentViewController(locationController, animated: true, completion: nil)
    }
    
    func getStudentLocations()
    {
        InfoClient.sharedInstance().getStudentLocations
        {
            (success, error) -> Void in
            
            if success
            {
                if (error == nil)
                {
                    //Store student locations in self variable
                    self.students = InfoClient.sharedInstance().students
                    
                    //Does the user's pin exist?
                    if let _ = InfoClient.sharedInstance().pinData
                    {
                        //Filter from subset of all pins
                        let removePinAnnotations = self.mapView!.annotations.filter()
                        {
                                $0 !== InfoClient.sharedInstance().pinData
                        }
                        
                        self.mapView!.removeAnnotations(removePinAnnotations)
                    }
                    else
                    {
                        self.mapView!.removeAnnotations(self.pinData)
                    }

                    self.loadData()
                    self.mapView!.addAnnotations(self.pinData)
                }
                else
                {
                    self.alertMessage("UNABLE TO GET LOCATIONS.")
                }
            }
            else
            {
                self.alertMessage("UNABLE TO GET LOCATIONS.")
            }
        }
    }

    func loadData()
    {
        if !self.students.isEmpty
        {
            pinData = [PinData]()
            
            for location in self.students
            {
                //Create new pinData for each student location
                let newPinData = PinData(title: "\(location.firstName) \(location.lastName)", urlString: location.mediaURL, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                    
                // Add the pinData to the array.
                pinData.append(newPinData)
            }
        }
    }
    
    func centerMapLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Gives access to annotation info box so that it can be tapped
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?
    {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        
        return view
    }
    
    //Opens mediaURL when annotation info box is tapped
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        //NSURL from the selected location mediaURL string - if it exists
        if let url = NSURL(string: view.annotation!.subtitle!!)
        {
            if validateURL(view.annotation!.subtitle!!)
            {
                UIApplication.sharedApplication().openURL(url)
            }
            else
            {
                self.alertMessage ("URL WAS NOT WELL FORMED.")
            }
        }
        else
        {
            self.alertMessage ("URL WAS NOT WELL FORMED.")
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
    }
    
    func validateURL(URL: String) -> Bool
    {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        
        if URL.rangeOfString(pattern, options: .RegularExpressionSearch) != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    func alertMessage(message: String)
    {
        let alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func delete()
    {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        var xsrfCookie: NSHTTPCookie? = nil
        
        request.HTTPMethod = "DELETE"
        
        for cookie in sharedCookieStorage.cookies!
        {
            if cookie.name == "XSRF-TOKEN"
            {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie
        {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request)
        {
            data, response, error in
            
            if error != nil
            {
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
    }
}










