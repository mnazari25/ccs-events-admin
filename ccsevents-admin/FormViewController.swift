//
//  FormViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/20/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class FormViewController: UIViewController {

    var ref : FIRDatabaseReference!
    
    @IBOutlet weak var daScrollView: UIScrollView!
    
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var adminNotesTextView: UITextView!
    @IBOutlet weak var eventImageView: UIImageView!
    
    var viewIsEditing : Bool = false
    var selectedEvent : Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child("ccs/events")
        
        daScrollView.contentSize.height = 950
        
        descriptionTextView.text = "Descripción del evento"
        descriptionTextView.textColor = .darkGray
        adminNotesTextView.text = "Notas administrativas"
        adminNotesTextView.textColor = .darkGray
        
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let event = selectedEvent else {
            // Enable textfields if no event was passed so the user can add an event.
            toggleTextfields(enabled: true)
            return
        }
        
        urlField.text = event.eventImage
        eventImageView.sd_setImage(with: URL(string: event.eventImage), placeholderImage: #imageLiteral(resourceName: "calendar"))
        eventNameField.text = event.eventName
        locationField.text = event.eventLocation
        startTimeField.text = "\(event.eventDate)"
        endTimeField.text = "\(event.eventDate)"
        
        descriptionTextView.text = event.eventDescription
        descriptionTextView.textColor = .black
        adminNotesTextView.text = event.eventDescription
        adminNotesTextView.textColor = .black
        
        toggleTextfields(enabled: false)
    }
    
    func toggleTextfields(enabled: Bool) {
        urlField.isEnabled = enabled
        eventNameField.isEnabled = enabled
        locationField.isEnabled = enabled
        startTimeField.isEnabled = enabled
        endTimeField.isEnabled = enabled
        descriptionTextView.isEditable = enabled
        adminNotesTextView.isEditable = enabled
    }
    
    func saveChangesIfNecessary(shouldSaveChanges: Bool) {
        
        // This means the done button was pressed and we should save the changes.
        // If the selectedEvent is nil, we should add the event and save it to Firebase. Assuming all necessary fields have been filled in.
        if shouldSaveChanges {
            print("YEAHHH")
            if urlField.hasText
                && eventNameField.hasText
                && locationField.hasText
                && startTimeField.hasText // Should change to event date
                && endTimeField.hasText // Should change to event time
                && descriptionTextView.hasText {
                
                // TODO: Save event to Firebase
                let eventToSave = [Constants.eventNameKey : eventNameField.text!,
                                    Constants.eventLocationKey : locationField.text!,
                                    Constants.eventDescriptionKey : descriptionTextView.text!,
                                    Constants.adminNotesKey : adminNotesTextView.text!,
                                    Constants.eventDateKey : u_long.init(startTimeField.text!) ?? 0,
                                    Constants.eventTimeKey : u_long.init(startTimeField.text!) ?? 0 ,
                                    Constants.eventImageKey : urlField.text!] as [String : Any]
                
                if selectedEvent == nil {
                    ref.childByAutoId().setValue(eventToSave)
                    
                    let countRef = FIRDatabase.database().reference(withPath: "MyNetwork/event_count")
                    countRef.observeSingleEvent(of: .value) { (snap : FIRDataSnapshot) in
                        guard var eventCount = snap.value as? Int else {
                            return
                        }
                        
//                        countRef.setValue(eventCount += 1)
                    }

                } else {
                    ref.child((selectedEvent?.key)!).setValue(eventToSave)
                }
                
            } else {
                // TODO: Notify user that all fields must be filled in.
            }
        }
    }
}

// MARK: - Notifications
extension FormViewController {
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(secondaryActionPress), name: NotificationCenter.SECONDARY_ACTION_NOTIFICATION, object: nil)
    }
    
    func secondaryActionPress(daNotification: NSNotification) {
        let isEditingFields = Bool(daNotification.object as! NSNumber)
        if selectedEvent != nil {
            toggleTextfields(enabled: isEditingFields)
        }
        saveChangesIfNecessary(shouldSaveChanges: !isEditingFields)
    }
}

// MARK: - Textfield Delegate Methods
extension FormViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.isEqual(urlField) {
            eventNameField.becomeFirstResponder()
            // Attempt to load url into imageview.
            guard let urlText = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return true }
        
            //TODO: Check if urltext is a valid url.
            if urlText.isEmpty {
                eventImageView.image = #imageLiteral(resourceName: "calendar")
            } else {
                eventImageView.sd_setImage(with: URL(string: urlText), placeholderImage: #imageLiteral(resourceName: "calendar"))
            }

        } else if textField.isEqual(eventNameField) {
            locationField.becomeFirstResponder()
        } else if textField.isEqual(locationField) {
            startTimeField.becomeFirstResponder()
        } else if textField.isEqual(startTimeField){
            endTimeField.becomeFirstResponder()
        } else if textField.isEqual(endTimeField) {
            descriptionTextView.becomeFirstResponder()
        }
        
        return true
    }
}

// MARK: - UITextViewDelegate
extension FormViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .darkGray {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            if textView.isEqual(descriptionTextView) {
                textView.text = "Descripción del evento"
            } else {
                textView.text = "Notas administrativas"
            }
            textView.textColor = .darkGray
        }
    }
}



