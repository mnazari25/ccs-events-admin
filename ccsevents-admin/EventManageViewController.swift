//
//  EventManageViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SDWebImage

class EventManageViewController: UIViewController {

    var ref: FIRDatabaseReference!
    
    let eventCellReuseID = "eventCellReuseID"
    
    //Outlets
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var addEventButton: UIButton!
    
    var selectedEvent : Event?
    var savedEvents : [Event] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = FIRDatabase.database().reference(withPath: "ccs/events")
        addEventButton.layer.cornerRadius = 6.0
        
        eventTableView.register(UINib.init(nibName: "EventTableViewCell", bundle: nil), forCellReuseIdentifier: eventCellReuseID)
        eventTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        eventTableView.allowsMultipleSelectionDuringEditing = false
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readAndListenForEvents()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func addEventButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toDetailVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? EventDetailViewController else  { return }
        detailVC.selectedEvent = selectedEvent
        selectedEvent = nil
    }
}

extension EventManageViewController : UITableViewDelegate, UITableViewDataSource {
    //MARK: Required Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: eventCellReuseID) as? EventTableViewCell else {
            return UITableViewCell()
        }
        
        let thisEvent = savedEvents[indexPath.row]
        
        getImageFromStorageRef(title: thisEvent.eventImage, imageView: cell.eventImage)

        cell.eventTitle.text = thisEvent.eventName
        cell.eventDesc.text = thisEvent.eventDescription
        
        let timeInterval : TimeInterval = TimeInterval(thisEvent.eventDate)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateStyle = .short
        dayTimePeriodFormatter.timeStyle = .long
        dayTimePeriodFormatter.timeZone = NSTimeZone.local
        dayTimePeriodFormatter.locale = Locale.init(identifier: "es_HN")
        let dateString = dayTimePeriodFormatter.string(from: date)
        cell.eventDate.text = "\(dateString)"
        
        return cell
    }
    
    //MARK: Optional Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = savedEvents[indexPath.row]
        self.performSegue(withIdentifier: "toDetailVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let theEventToDestroy = savedEvents[indexPath.row]
            ref.child(theEventToDestroy.key).removeValue()
        }
    }
}

// MARK: - CRUD Functionality
extension EventManageViewController {
    func readAndListenForEvents() {
        ref.queryOrderedByKey().observe(.value) { (snap : FIRDataSnapshot) in
            
            // Clear old list to make room for new events
            self.savedEvents = []
            
            if snap.hasChildren() {
                // Loop through all event children
                for child in snap.children {
                    // Create new event object using Data snapshot
                    let newEvent = Event(snapshot: child as! FIRDataSnapshot)
                    // Add new event to saved event list
                    self.savedEvents.append(newEvent)
                }
                self.savedEvents = self.savedEvents.reversed()
            }
            
            UserDefaults.standard.set(self.savedEvents.count, forKey: "eventCount")
            let countRef = FIRDatabase.database().reference(withPath: "MyNetwork/event_count")
            countRef.setValue(self.savedEvents.count)
            
            // Reload table
            self.eventTableView.reloadData()
        }
    }
}
