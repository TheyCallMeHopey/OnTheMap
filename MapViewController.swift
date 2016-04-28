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
        
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func pinButton(sender: AnyObject)
    {
        findLocation()
    }
    
    @IBAction func refreshButton(sender: AnyObject)
    {
        getStudentLocations()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        getStudentLocations()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        centerMapLocation(InfoClient.sharedInstance().currentLocation!)
        
        if let pin = InfoClient.sharedInstance().pinData
        {
            self.mapView!.addAnnotation(pin)
        }
    }
    
    //Allow the user to set/update their location
    func findLocation()
    {
        let locationController = self.storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        
        self.presentViewController(locationController, animated: true, completion: nil)
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

    
    func alertMessage(message: String)
    {
        let alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}











