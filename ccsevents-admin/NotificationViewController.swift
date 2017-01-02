//
//  NotificationViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit
import AFNetworking

class NotificationViewController: UIViewController {

    //Outlet
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var notificationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationButton.layer.cornerRadius = 6.0
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        //TODO: Get info from fields
        //TODO: form JSON 
        //TODO: post to url?? Maybe... wtf!
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
    
    }
}
