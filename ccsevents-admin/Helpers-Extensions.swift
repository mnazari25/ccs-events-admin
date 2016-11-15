//
//  Helpers-Extensions.swift
//  ccsevents-admin
//
//  Created by Amir Nazari on 10/21/16.
//  Copyright © 2016 Amir Nazari. All rights reserved.
//

import Foundation
import UIKit


/// http://stackoverflow.com/a/38094664
extension UIToolbar {
    
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
    
}
