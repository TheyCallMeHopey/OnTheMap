//
//  LocationViewController.swift
//  On The Map
//
//  Created by Hope on 3/30/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import AddressBook
import CoreLocation
import MapKit
import UIKit

class LocationViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate
{
    var newLocation: Bool = true
    
    var userLocation: StudentLocation?
    
    @IBOutlet weak var locationAndURLTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveURLButton: UIButton!
    @IBOutlet weak var findOnTheMapButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func cancelButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveURLButton(sender: AnyObject)
    {
        locationAndURLTextField.resignFirstResponder()
        
        if !self.locationAndURLTextField.text!.isEmpty
        {
            //Get a copy of the text from the text field.
            let text = self.locationAndURLTextField.text
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.activityIndicator.startAnimating()
            }
            
            self.userLocation!.mediaURL = text!
            
            InfoClient.sharedInstance().userLocation = self.userLocation!
            
            //Check if user has an existing location
            if newLocation
            {
                //Create user's location
                InfoClient.sharedInstance().createUserLocation(
                {
                    (success, error) -> Void in
                        
                    if success
                    {
                        //Update student locations, then present UITabBarController.
                        self.returnToRootController()
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    else
                    {
                        self.alertMessage (error!)
                    }
                })
            }
            else
            {
                InfoClient.sharedInstance().updateUserLocation(
                {
                    (success, error) -> Void in
                    
                    if success
                    {
                        self.returnToRootController()
                        
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                    else
                    {
                        self.alertMessage(error!)
                    }
                })
            }
        }
        else
        {
            self.alertMessage("TEXT FIELD WAS EMPTY. PLEASE ENTER PROPER URL.")
        }
    }
    
    @IBAction func findOnTheMapButton(sender: AnyObject)
    {
        if !self.locationAndURLTextField.text!.isEmpty
        {
            findOnTheMapButton.hidden = false
            activityIndicator.hidden = false
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.activityIndicator.startAnimating()
            }
            
            let geoCoder = CLGeocoder()
            
            //Get geocode address from the text field and set student location variables
            geoCoder.geocodeAddressString(self.locationAndURLTextField.text!, completionHandler:
            {
                (placemarks:[CLPlacemark]?, error:NSError?) -> Void in
                
                if let Error = error
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    self.alertMessage("INVALID LOCATION.")
                    
                    print("GEOCODE FAILED WITH ERROR: \(Error.localizedDescription)")
                }
                else if placemarks!.count > 0
                {
                    dispatch_async(dispatch_get_main_queue())
                    {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    let place = placemarks![0] 
                    let location = place.location
                    
                    self.coordinates = location!.coordinate
                    self.userLocation!.latitude = self.coordinates!.latitude
                    self.userLocation!.longitude = self.coordinates!.longitude
                    
                    //String of location address
                    self.userLocation!.mapString = "\(place.locality), \(place.administrativeArea), \(place.country)"
                    
                    //Zoom and center for the confirmation map at the top of the page
                    self.setCenterLocation()
                    self.centerMapLocation(InfoClient.sharedInstance().currentLocation!)
                    
                    //Create a pin annotation for the map
                    self.pinData = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                
                    self.mapView.addAnnotation(self.pinData!)
                    
                    //Change the text field
                    self.locationAndURLTextField.text = ""
                    self.locationAndURLTextField.placeholder = "ENTER URL"
                    
                    dispatch_async(dispatch_get_main_queue())
                    {
                        self.activityIndicator.stopAnimating()
                    }
                    
                    self.activityIndicator.hidden = true
            
                    self.saveURLButton.hidden = false
                    self.findOnTheMapButton.hidden = true
                }
            })
        }
        else
        {
            alertMessage("TEXT FIELD WAS EMPTY. PLEASE ENTER PROPER LOCATION.")
            
            saveURLButton.hidden = true
            findOnTheMapButton.hidden = false
        }
    }
    
    //Zooming in
    let regionRadius: CLLocationDistance = 50000
    var locationManager = CLLocationManager()
    var coordinates: CLLocationCoordinate2D?
    
    //Show the user's location with pin annotation
    var placemark: CLPlacemark!
    var pinData:PinData?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        locationAndURLTextField.hidden = false
        findOnTheMapButton.hidden = false
        activityIndicator.hidden = true
        saveURLButton.hidden = true
        
        locationAndURLTextField.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        
        //Does user already have a location stored?
        InfoClient.sharedInstance().searchStudentLocation(
        {
            (success, error) -> Void in
            
            //Was a previous location found?
            if success
            {
                if (error == nil)
                {
                    if(InfoClient.sharedInstance().userLocation == nil)
                    {
                        self.alertMessage("NO LOCATION FOUND.")
                    }
                    else
                    {
                        //Variables for existing location
                        self.newLocation = false
                        self.userLocation = InfoClient.sharedInstance().userLocation
                        
                        let previousLocation = self.userLocation!.mapString
                        
                        self.locationAndURLTextField.text = "\(previousLocation)"
                    }
                }
                else
                {
                    //Dictionary of location values
                    let locationDictionary = InfoClient.createUserLocation()
                    
                    //Create student location with the location dictionary
                    self.userLocation = StudentLocation(dictionary: locationDictionary)
                    self.userLocation = InfoClient.sharedInstance().userLocation
                    
                    self.newLocation = true
                }
            }
        })
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //Follow the user's current location
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)

        checkLocationAuthorizationStatus()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    func setCenterLocation()
    {
        InfoClient.sharedInstance().currentLocation = CLLocation(latitude: self.userLocation!.latitude, longitude: self.userLocation!.longitude)
    }
    
    func centerMapLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Adjust location variables as current locations ae updated
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler:
        {
            (placemarks, error) -> Void in
            
            if (error != nil)
            {
                self.alertMessage ("REVERSE GEOCODER FAILED WITH ERROR: " + error!.localizedDescription)
            }
            
            //Is there at least one location in the placemarks array?
            if placemarks!.count > 0
            {
                self.locationManager.stopUpdatingLocation()
                
                self.placemark = placemarks![0]
                
                if let place = self.placemark
                {
                    self.locationAndURLTextField.text = "\(place.locality), \(place.administrativeArea)  \(place.country)"
                    
                    print(place.locality)
                    print(place.administrativeArea)
                    print(place.postalCode)
                    print(place.country)
                }
            }
        })
    }
    
    //Adjust location variables in map view as authorization status changed
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus)
    {
        self.mapView.showsUserLocation = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        self.alertMessage ("ERROR WHILE UPDATION INFORMATION " + error.localizedDescription)
    }
    
    func returnToRootController()
    {
        InfoClient.sharedInstance().getStudentLocations(
        {
            (success, error) -> Void in
            
            if success
            {
                if (error == nil)
                {
                    self.setCenterLocation()

                    //let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
                    
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    //Create pin data to add to the annotations on UITabBarController and store on the InfoClient
                    InfoClient.sharedInstance().pinData = PinData(title: "\(self.userLocation!.firstName) \(self.userLocation!.lastName)", urlString: "\(self.userLocation!.mediaURL)", coordinate: self.coordinates!)
                }
                else
                {
                    self.alertMessage(error!)
                }
            }
        })
    }
    
    func checkLocationAuthorizationStatus()
    {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
        {
            mapView.showsUserLocation = true
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func alertMessage(message: String)
    {
        let alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}












