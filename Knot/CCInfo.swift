//
//  CCInfo.swift
//  Knot
//
//  Created by Nathan Mueller on 5/10/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class CCInfo: UIViewController{

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var cvcField: UITextField!
    @IBOutlet weak var expDate: UITextField!
    @IBOutlet weak var CCNum: UITextField!
    @IBOutlet weak var receiptLabel: UILabel!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var fee = 0.01
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fee = Double(appDelegate.item.price)! * 0.04
        
        self.receiptLabel.text = "Service Fee (4%): " + String(fee)
        
    }

    @IBAction func saveButton(sender: AnyObject) {
        
        let alert = UIAlertController(title: "Confirm Payment", message: "Make payment of $" + String(fee) + "?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alertAction) -> Void in
            SwiftSpinner.show("Completing Transaction")
            let delayInSeconds = 2.5;
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                // When done requesting/reloading/processing invoke endRefreshing, to close the control
                SwiftSpinner.hide()
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller")
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller")
                self.presentViewController(vc, animated: true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}
