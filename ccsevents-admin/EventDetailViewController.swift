//
//  EventDetailViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/9/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var secondaryActionButton: UIButton!
    
    var selectedEvent : Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.layer.cornerRadius = 6.0
        secondaryActionButton.layer.cornerRadius = 6.0
        
        if selectedEvent == nil {
            secondaryActionButton.setTitle("Guardar Evento", for: .normal)
            //TODO: Set button color
        }
    }
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func secondaryActionPressed(_ sender: UIButton) {
        
        var shouldEdit = false
        
        if selectedEvent != nil {
            if secondaryActionButton.titleLabel?.text == "Editar" {
                shouldEdit = true
                secondaryActionButton.setTitle("Hecho", for: .normal)
                //TODO: Set button color
            } else {
                secondaryActionButton.setTitle("Editar", for: .normal)
                //TODO: Set button color
            }
        }
        NotificationCenter.default.post(name: NotificationCenter.SECONDARY_ACTION_NOTIFICATION, object: shouldEdit)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let formVC = segue.destination as? FormViewController,
            selectedEvent != nil else { return }
        formVC.selectedEvent = selectedEvent
    }
}
