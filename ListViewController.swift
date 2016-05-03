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
        let studentLocation = students[indexPath.row]
        
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("TableCell")! as UITableViewCell
       
        cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "TableCell")

        cell.textLabel!.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        
        return cell
    }
    
    //Row selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        //NSURL from the selected location mediaURL string - if it exists
        if let url = NSURL(string: students[indexPath.row].mediaURL)
        {
            if validateURL(students[indexPath.row].mediaURL) == true
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
    }
    
    //Allow the user to set/update their location
    func findLocation()
    {
        let locationController = storyboard!.instantiateViewControllerWithIdentifier("LocationViewController") as! LocationViewController
        
        presentViewController(locationController, animated: true, completion: nil)
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
}














