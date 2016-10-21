//
//  ViewController.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/8/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var userAction = false
    var isExpanded = false
    
    let menuCellReuse = "menuCellReuse"
    let menuItems = ["Evento", "Galería", "Notificación", "Información"]
    let menuImages = [#imageLiteral(resourceName: "calendar"), #imageLiteral(resourceName: "gallery"), #imageLiteral(resourceName: "notification"), #imageLiteral(resourceName: "info")]
    
    // Outlets
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var eventContainer: UIView!
    @IBOutlet weak var galleryContainer: UIView!
    @IBOutlet weak var notificationContainer: UIView!
    @IBOutlet weak var informationContainer: UIView!
    @IBOutlet weak var menuLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        menuTableView.tableFooterView = UIView(frame: CGRect.zero)
        menuTableView.selectRow(at: IndexPath.init(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
        
        eventContainer.isHidden = false
        galleryContainer.isHidden = true
        notificationContainer.isHidden = true
        informationContainer.isHidden = true
        
        registerNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if userAction {
            userAction = false
            return
        }
        
        animateMenuBar(open: isExpanded, speed: 0.1)
    }
    
    @IBAction func menuButtonPressed(_ sender: UIBarButtonItem) {
        userAction = true
        isExpanded = !isExpanded
        animateMenuBar(open: isExpanded)
    }
    
    func animateMenuBar(open : Bool, speed: Double = 0.5) {
        if !open {
            self.menuLeadingConstraint.constant = -self.menuTableView.frame.width
            UIView.animate(withDuration: speed, animations: {
                self.view.layoutIfNeeded()
            })
            
        } else {
            self.menuLeadingConstraint.constant = 0
            UIView.animate(withDuration: speed, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Required Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: menuCellReuse) as? MenuTableViewCell else {
            return UITableViewCell()
        }
        
        cell.contentView.backgroundColor = UIColor.darkGray
        cell.menuTitle.text = menuItems[indexPath.row]
        cell.menuImage.image = menuImages[indexPath.row]
        
        return cell 
    }
    
    //MARK: Optional Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            eventContainer.isHidden = false
            galleryContainer.isHidden = true
            notificationContainer.isHidden = true
            informationContainer.isHidden = true
        case 1:
            eventContainer.isHidden = true
            galleryContainer.isHidden = false
            notificationContainer.isHidden = true
            informationContainer.isHidden = true
        case 2:
            eventContainer.isHidden = true
            galleryContainer.isHidden = true
            notificationContainer.isHidden = false
            informationContainer.isHidden = true
        case 3:
            eventContainer.isHidden = true
            galleryContainer.isHidden = true
            notificationContainer.isHidden = true
            informationContainer.isHidden = false
        default:
            break
        }
    }
}

// MARK: - Notifications
extension ViewController {
    func registerNotifications() {
        //TODO: Register any notifications here
    }
}

