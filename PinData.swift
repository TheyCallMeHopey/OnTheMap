//
//  PinData.swift
//  On The Map
//
//  Created by Hope on 4/15/16.
//  Copyright © 2016 Hope Elizabeth. All rights reserved.
//

import Foundation
import AddressBook
import MapKit

class PinData: NSObject, MKAnnotation
{
    let title: String?
    let urlString: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, urlString: String, coordinate: CLLocationCoordinate2D)
    {
        self.title = title
        self.urlString = urlString
        self.coordinate = coordinate
        
        super.init()
    }
    
    //Subtitle value of a pin
    var subtitle: String?
    {
        return urlString
    }
}

