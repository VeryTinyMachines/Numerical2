//
//  InterfaceController.swift
//  Numerical2-Watch Extension
//
//  Created by Kevin Enax on 10/8/15.
//  Copyright © 2015 Very Tiny Machines. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController {

    @IBOutlet var mainLabel: WKInterfaceLabel!
    @IBOutlet var subLabel: WKInterfaceLabel!
    

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func gridButtonPressed() {
        
    }
    
    @IBAction func speechButtonPressed() {
        presentTextInputControllerWithSuggestions(nil, allowedInputMode: .Plain) { (results) -> Void in
            if let strings : [String] = results as? [String] where results!.count > 0 {
                self.mainLabel.setText(strings.reduce("") { wholeString, partial in return wholeString! + partial })
            }
        }
    }
}
