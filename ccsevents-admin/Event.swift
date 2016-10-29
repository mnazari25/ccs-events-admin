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
    var eventImage : String = ""
    var adminNotes : String = ""
    
    init(eventName : String, eventDate : String,
         eventLocation : String, eventTime : String,
         eventDescription : String, eventImage : String, adminNotes : String = "") {

        self.eventName = eventName
        self.eventDate = eventDate
        self.eventLocation = eventLocation
        self.eventDescription = eventDescription
        self.eventTime = eventTime
        self.eventImage = eventImage
        self.adminNotes = adminNotes
    }
    
    init(snapshot : FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: Any]
        
        //TODO: Make this safer by adding nil checks on returned snapshot items
        eventName = snapshotValue[Constants.eventNameKey] as! String
        eventDate = snapshotValue[Constants.eventDateKey] as! String
        eventLocation = snapshotValue[Constants.eventLocationKey] as! String
        eventDescription = snapshotValue[Constants.eventDescriptionKey] as! String
        eventTime = snapshotValue[Constants.eventTimeKey] as! String
        eventImage = snapshotValue[Constants.eventImageKey] as! String
        adminNotes = snapshotValue[Constants.adminNotesKey] as! String
        
    }
    
}
