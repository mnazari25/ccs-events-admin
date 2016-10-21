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
        
        readAndListenForEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        if indexPath.row == 1 {
            cell.eventImage.image = #imageLiteral(resourceName: "gallery")
        }
        
        cell.eventTitle.text = thisEvent.eventName
        cell.eventDesc.text = thisEvent.eventDescription
        cell.eventDate.text = thisEvent.eventDate
        
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
}

// MARK: - CRUD Functionality
extension EventManageViewController {
    func readAndListenForEvents() {
        ref.queryOrderedByKey().observe(.value) { (snap : FIRDataSnapshot) in
            if snap.hasChildren() {
                // Clear old list to make room for new events
                self.savedEvents = []
                // Loop through all event children
                for child in snap.children {
                    // Create new event object using Data snapshot
                    let newEvent = Event(snapshot: child as! FIRDataSnapshot)
                    // Add new event to saved event list
                    self.savedEvents.append(newEvent)
                }
                // Reload table
                self.eventTableView.reloadData()
            }
        }
    }
}
