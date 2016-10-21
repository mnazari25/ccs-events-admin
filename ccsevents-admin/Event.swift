//
//  Event.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/5/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class Event : NSObject {
    var key : String = ""
    var eventName : String = ""
    var eventDate : String = ""
    var eventLocation : String = ""
    var eventTime : String = ""
    var eventDescription : String = ""
    var eventImage : UIImage = UIImage()
    
    init(eventName : String, eventDate : String,
         eventLocation : String, eventTime : String,
         eventDescription : String, eventImage : UIImage) {

        self.eventName = eventName
        self.eventDate = eventDate
        self.eventLocation = eventLocation
        self.eventDescription = eventDescription
        self.eventTime = eventTime
        self.eventImage = eventImage
        
    }
    
    init(snapshot : FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: Any]
        
        //TODO: Make this safer by adding nil checks on returned snapshot items
        eventName = snapshotValue["eventName"] as! String
        eventDate = snapshotValue["eventDate"] as! String
        eventLocation = snapshotValue["eventLocation"] as! String
        eventDescription = snapshotValue["eventDescription"] as! String
    }
    
}
