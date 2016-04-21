//
//  WebViewController.swift
//  On The Map
//
//  Created by Hope on 4/20/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import UIKit

class WebViewController: UIViewController, UIWebViewDelegate
{
    var authenticating: Bool = true
    var urlRequest: NSURLRequest? = nil
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBAction func cancelButton(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        webView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if authenticating
        {
            navigationBar.hidden = false
        }
        else
        {
            navigationBar.hidden = true
            
            if InfoClient.sharedInstance().loggedIn
            {
                //Move into the MapListTabBarController
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapListTabBarController") as! UITabBarController
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
            else
            {
                //Go back to LoginViewController
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        
        if urlRequest != nil
        {
            self.webView.loadRequest(urlRequest!)
        }
    }
}