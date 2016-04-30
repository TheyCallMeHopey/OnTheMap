//
//  ListViewController.swift.swift
//  On The Map
//
//  Created by Hope on 3/30/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    var students:[StudentLocation] = [StudentLocation]()
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)

        self.students = InfoClient.sharedInstance().students

        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return students.count
    }
    
    //Format cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("TableCell") as UITableViewCell!
        let studentLocation = students[indexPath.row]
        
        cell.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell.detailTextLabel!.text = studentLocation.mediaURL
        
        return cell
    }
    
    //Row selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //Instance of WebViewController
        let detailController = storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        
        //NSURL from the selected location mediaURL string - if it exists
        if let url = NSURL(string: students[indexPath.row].mediaURL)
        {
            UIApplication.sharedApplication().openURL(url)

            detailController.urlRequest = NSURLRequest(URL: url)

            self.presentViewController(detailController, animated: true, completion: nil)
        }
        else
        {
            self.alertMessage ("URL WAS NOT WELL FORMED.")
        }
    }
    
    //Allow the user to set/update their location
    func findLocation()
    {
        let locationController = storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        
        self.presentViewController(locationController, animated: true, completion: nil)
    }
    
    func getStudentLocations()
    {
        InfoClient.sharedInstance().getStudentLocations
        {
            (success, error) -> Void in
                
            if success
            {
                self.students = InfoClient.sharedInstance().students
            }
            else
            {
                self.alertMessage("UNABLE TO GET LOCATIONS.")
            }
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














