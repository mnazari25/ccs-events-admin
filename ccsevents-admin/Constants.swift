//
//  Constants.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/21/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import Foundation

extension NotificationCenter {
    static var SECONDARY_ACTION_NOTIFICATION : NSNotification.Name {
        return NSNotification.Name(rawValue: "SECONDARY_ACTION_NOTIFICATION")
    }
}

class Constants {
    static let adminNotesKey = "adminNotes"
    static let eventNameKey = "eventName"
    static let eventDateKey = "eventDate"
    static let eventLocationKey = "eventLocation"
    static let eventDescriptionKey = "eventDescription"
    static let eventTimeKey = "eventTime"
    static let eventImageKey = "eventImage"
    
    // Notification
    static let notificationTitleKey = "notificationTitle"
    static let notificationMessageKey = "notificationMessage"
    static let notificationDateKey = "notificationDate"
}
