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
    
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var adminNotesTextView: UITextView!
    @IBOutlet weak var eventImageView: UIImageView!
    
    var viewIsEditing : Bool = false
    var selectedEvent : Event?
    var didChangeImage : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = FIRDatabase.database().reference().child("ccs/events")
        
        daScrollView.contentSize.height = 1350
        
        descriptionTextView.text = "Descripción del evento"
        descriptionTextView.textColor = .darkGray
        adminNotesTextView.text = "Notas administrativas"
        adminNotesTextView.textColor = .darkGray
        
        let toolBar = makeToolBarPicker(mySelect: #selector(FormViewController.donePressed))
        descriptionTextView.inputAccessoryView = toolBar
        adminNotesTextView.inputAccessoryView = toolBar
        
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let event = selectedEvent else {
            // Enable textfields if no event was passed so the user can add an event.
            toggleTextfields(enabled: true)
            return
        }
        
        if !didChangeImage {
            getImageFromStorageRef(title: event.eventImage, imageView: eventImageView)
        }
        
        eventNameField.text = event.eventName
        locationField.text = event.eventLocation
        
        let timeInterval : TimeInterval = TimeInterval(event.eventDate)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .full
        dayTimePeriodFormatter.timeStyle = .none
        dayTimePeriodFormatter.locale = Locale.init(identifier: "es_HN")
        let dateString = dayTimePeriodFormatter.string(from: date)
        dateField.text = dateString
 
        let timePeriodFormatter = DateFormatter()
        timePeriodFormatter.dateStyle = .none
        timePeriodFormatter.timeStyle = .long
        timePeriodFormatter.timeZone = NSTimeZone.local
        let timeString = timePeriodFormatter.string(from: date)
        
        timeField.text = timeString
        
        descriptionTextView.text = event.eventDescription
        descriptionTextView.textColor = .black
        adminNotesTextView.text = event.adminNotes
        adminNotesTextView.textColor = .black
        
        toggleTextfields(enabled: false)
    }
    
    func resetUI() {
        didChangeImage = false
        eventNameField.text = ""
        locationField.text = ""
        dateField.text = ""
        timeField.text = ""
        descriptionTextView.text = ""
        adminNotesTextView.text = ""
        eventImageView.image = #imageLiteral(resourceName: "calendar")
    }
    
    func toggleTextfields(enabled: Bool) {
        viewIsEditing = enabled
        eventNameField.isEnabled = enabled
        locationField.isEnabled = enabled
        dateField.isEnabled = enabled
        timeField.isEnabled = enabled
        descriptionTextView.isEditable = enabled
        adminNotesTextView.isEditable = enabled
    }
    
    func makeToolBarPicker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    @IBAction func textFieldEntered(_ sender: UITextField) {
        let toolBar = makeToolBarPicker(mySelect: #selector(FormViewController.donePressed))
        if sender.isEqual(dateField) {
            let datePickerView  : UIDatePicker = UIDatePicker()
            datePickerView.datePickerMode = UIDatePickerMode.date
            datePickerView.locale = Locale.init(identifier: "es_HN")
            dateField.inputView = datePickerView
            dateField.inputAccessoryView = toolBar
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: UIControlEvents.valueChanged)
            
            handleDatePicker(sender: datePickerView)
        } else if sender.isEqual(timeField) {
            let timePickerView  : UIDatePicker = UIDatePicker()
            timePickerView.datePickerMode = UIDatePickerMode.time
            
            if (timeField.text?.isEmpty)! {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat =  "HH:mm"
                let date = dateFormatter.date(from: "12:00")
                
                timePickerView.setDate(date!, animated: true)
            } else {
                let timePeriodFormatter = DateFormatter()
                timePeriodFormatter.dateStyle = .none
                timePeriodFormatter.timeStyle = .long
                let date = timePeriodFormatter.date(from: timeField.text!)
                timePickerView.setDate(date!, animated: true)
            }
            
            timeField.inputView = timePickerView
            timeField.inputAccessoryView = toolBar
            timePickerView.addTarget(self, action: #selector(handleTimePicker(sender:)), for: UIControlEvents.valueChanged)
            
            handleTimePicker(sender: timePickerView)
        }
    }
    
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.init(identifier: "es_HN")
        dateField.text = dateFormatter.string(from: sender.date)
    }
    
    func donePressed() {
        dateField.resignFirstResponder()
        timeField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        adminNotesTextView.resignFirstResponder()
    }
    
    func handleTimePicker(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .long
        timeField.text = timeFormatter.string(from: sender.date)
    }
    
    func saveChangesIfNecessary(shouldSaveChanges: Bool) {
        
        // This means the done button was pressed and we should save the changes.
        // If the selectedEvent is nil, we should add the event and save it to Firebase. Assuming all necessary fields have been filled in.
        if shouldSaveChanges {        
            if eventNameField.hasText
                && locationField.hasText
                && dateField.hasText // Should change to event date
                && timeField.hasText // Should change to event time
                && descriptionTextView.hasText {
                
                // Convert textfield for date and time into NSDate Unix timestamp value.
                let dateLong : u_long = textFieldsToNSDate(dateText: dateField, timeText: timeField)
                
                // TODO: Remove old image from firebase before saving new one.
                var imageTitle = ""
                
                if didChangeImage {
                    guard let image = eventImageView.image else { return }
                    
                    let resizedImage = resizeImage(image: image, newWidth: 400)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyyMMddhhmmss"
                    imageTitle = dateFormatter.string(from: Date())
                    
                    guard let data = UIImagePNGRepresentation(resizedImage) else {
                        return
                    }
                    saveImageToFirebaseStorage(data: data, title: imageTitle)
                } else {
                    if let event = selectedEvent {
                        imageTitle = event.eventImage
                    }
                }
                
                let eventToSave = [Constants.eventNameKey : eventNameField.text!,
                                    Constants.eventLocationKey : locationField.text!,
                                    Constants.eventDescriptionKey : descriptionTextView.text!,
                                    Constants.adminNotesKey : adminNotesTextView.text!,
                                    Constants.eventDateKey : dateLong,
                                    Constants.eventTimeKey : dateLong,
                                    Constants.eventImageKey : imageTitle] as [String : Any]
                
                if selectedEvent == nil {
                    let alert = UIAlertController(title: "Evento Guardado", message: "El evento se ha guardado en la base de datos.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "De Acuerdo", style: .default, handler: nil))
                    present(alert, animated: true, completion: {
                        
                        self.resetUI()
                        
                    })
                    ref.childByAutoId().setValue(eventToSave)
                } else {
                    ref.child((selectedEvent?.key)!).setValue(eventToSave)
                }
                
            } else {
                // TODO: Notify user that all fields must be filled in.
                let alert = UIAlertController(title: "Forma Incompleta", message: "Por favor llene los campos requeridos", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "De Acuerdo", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Takes in date and time strings and returns Unix timestamp for combined date.
    func textFieldsToNSDate(dateText : UITextField, timeText : UITextField) -> u_long {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale.init(identifier: "es_HN")
        let date = dateFormatter.date(from: dateText.text!)
        print(date?.description ?? "Uh oh spaghettios")
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .long
        let time = timeFormatter.date(from: timeText.text!)
        print(time?.description ?? "No time for you")
        
        let calendar = Calendar.current
        
        let componentsOne = calendar.dateComponents([Calendar.Component.year, Calendar.Component.month, Calendar.Component.day], from: date!)
        let componentsTwo = calendar.dateComponents([Calendar.Component.hour, Calendar.Component.minute], from: time!)
        
        var totalComponents = DateComponents()
        totalComponents.year = componentsOne.year
        totalComponents.month = componentsOne.month
        totalComponents.day = componentsOne.day
        totalComponents.hour = componentsTwo.hour
        totalComponents.minute = componentsTwo.minute
        
        let finalDate = calendar.date(from: totalComponents)
        
        print(finalDate?.description ?? "Final date fail")
        print("\(u_long((finalDate?.timeIntervalSince1970)!))")
        return u_long((finalDate?.timeIntervalSince1970)!)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        
        if viewIsEditing {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension FormViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            didChangeImage = true
            
            eventImageView.contentMode = .scaleAspectFit
            eventImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        
        if textField.isEqual(eventNameField) {
            locationField.becomeFirstResponder()
        } else if textField.isEqual(locationField) {
            dateField.becomeFirstResponder()
        } else if textField.isEqual(dateField){
            timeField.becomeFirstResponder()
        } else if textField.isEqual(timeField) {
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



