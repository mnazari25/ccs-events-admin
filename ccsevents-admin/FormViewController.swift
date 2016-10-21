//
//  FormViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/20/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit

class FormViewController: UIViewController {

    @IBOutlet weak var daScrollView: UIScrollView!
    
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var eventNameField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var adminNotesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        daScrollView.contentSize.height = 1500
    }
}
