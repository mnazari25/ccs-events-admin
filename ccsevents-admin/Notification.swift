//
//  Notification.swift
//  ccs_events
//
//  Created by Amir Nazari on 1/5/17.
//  Copyright © 2017 Amir Nazari. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class CustomNotification : NSObject {
    var key : String = ""
    var messageTitle : String = ""
    var message : String = ""
    var date : String = ""

    init(messageTitle : String, message : String, date: String) {
        
        self.messageTitle = messageTitle
        self.message = message
        self.date = date
        
    }
    
    init(snapshot : FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: Any]
        
        //TODO: Make this safer by adding nil checks on returned snapshot items
        messageTitle = snapshotValue[Constants.notificationTitleKey] as! String
        message = snapshotValue[Constants.notificationMessageKey] as! String
        if let dateObject = snapshotValue[Constants.notificationDateKey] as? String {
            date = dateObject
        }
    }
    
}

