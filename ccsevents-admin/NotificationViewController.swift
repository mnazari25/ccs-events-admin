//
//  NotificationViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit
import AFNetworking
import Firebase

class NotificationViewController: UIViewController {

    var ref : FIRDatabaseReference!
    
    //Outlet
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var notificationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child("ccs/notifications")
        
        notificationButton.layer.cornerRadius = 6.0
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {

        if (titleTextField.text?.isEmpty)! || (messageTextField.text?.isEmpty)! {
            // TODO: Alert user that textfields are empty.
            let alert = UIAlertController(title: "Forma Incompleta", message: "Por favor llene los campos requeridos", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "De Acuerdo", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        // Trigger remote notification
        let manager = AFHTTPSessionManager()
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")
        manager.requestSerializer.setValue("key=AAAARRh04t4:APA91bEck2xAk5w4OmY618olFG3XyGJpnxoPmYsf3Ni9wY5YceNYe7v_BwDxNwrR-n5NskiuXIrnQ2lcK0NhIx8V9F-6PagwK4TRj3Gs9vAJs3rRcIPiNTh4bvuSojCmMINvhNuw4D8vBar2RW3UOxV7R0-6FezBtw", forHTTPHeaderField: "Authorization")
        
        let requestParameters = [
            "to" : "/topics/event",
            "notification" : [
                "title" : titleTextField.text,
                "body" : messageTextField.text
            ]
        ] as [String : Any]
        
        let url = "https://fcm.googleapis.com/fcm/send"
        
        manager.post(url, parameters: requestParameters, progress: nil, success:
            {
                requestOperation, response in
            
                let result = NSString(data: (response as! NSData) as Data, encoding: String.Encoding.utf8.rawValue)!
            
                print(result)
        }) {
            requestOperation, error in

            print(error.localizedDescription)
        }
    
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        let now = Date()
        let date = formatter.string(from: now)
        
        // Store notification to database
        let notificationObject = [Constants.notificationTitleKey : titleTextField?.text,
                                  Constants.notificationMessageKey : messageTextField?.text,
                                  Constants.notificationDateKey : date]
        
        ref.childByAutoId().setValue(notificationObject)
        readAndListenForEvents()
    }
}

// MARK: - CRUD Functionality
extension NotificationViewController {
    func readAndListenForEvents() {
        ref.queryOrderedByKey().observe(.value) { (snap : FIRDataSnapshot) in
            
            // Clear old list to make room
            var savedNotifications : [CustomNotification] = []
            
            if snap.hasChildren() {
                // Loop through all event children
                for child in snap.children {
                    // Create new event object using Data snapshot
                    let newNotification = CustomNotification(snapshot: child as! FIRDataSnapshot)
                    // Add new event to saved event list
                    savedNotifications.append(newNotification)
                }
                savedNotifications = savedNotifications.reversed()
            }
            
            UserDefaults.standard.set(savedNotifications.count, forKey: "notificationCount")
            let countRef = FIRDatabase.database().reference().child("MyNetwork/notifications")
            countRef.setValue(savedNotifications.count)
        }
    }
}
