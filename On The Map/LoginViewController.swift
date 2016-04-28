//
//  LoginViewController.swift
//  On The Map
//
//  Created by Hope on 3/30/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func signUpButton(sender: AnyObject)
    {
       //Open web for sign up
        let webController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        
        webController.urlRequest = NSURLRequest(URL: url!)
        
        self.presentViewController(webController, animated: true, completion: nil)
    }
    
    @IBAction func logInButton(sender: AnyObject)
    {
        let userID = emailTextField.text
        let userPassword = passwordTextField.text
        
        if userID == ""
        {
            alertMessage("PLEASE ENTER EMAIL ADDRESS.")
        }
        else
        {
            if userPassword == ""
            {
                alertMessage("PLEASE ENTER PASSWORD.")
            }
            else
            {
               //Authenticate userID and password
                InfoClient.sharedInstance().userID = userID
                InfoClient.sharedInstance().password = userPassword
                
                InfoClient.sharedInstance().authenticateWithLogIn(self, completionHandler:
                {
                    (success, error) -> Void in
                    
                    if success
                    {
                        InfoClient.sharedInstance().loggedIn = true
                        
                        print("LOGGING IN")
                        
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("UITabBarController") as! UITabBarController
                        
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                    else
                    {
                        InfoClient.sharedInstance().loggedIn = false
                        
                        self.alertMessage("UNABLE TO AUTHENTICATE LOG IN INFORMATION.")
                    }
                })
            }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewWillAppear(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func alertMessage(message: String)
    {
        let alertController = UIAlertController(title: "", message: "\(message)", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}
















