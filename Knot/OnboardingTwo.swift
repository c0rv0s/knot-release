//
//  OnboardingTwo.swift
//  Knot
//
//  Created by Nathan Mueller on 4/20/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK
import CoreLocation

class OnboardingTwo: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var logoPic: UIImageView!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    var first = true
    
    //location
    var locationManager: OneShotLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func yesButton(sender: AnyObject) {
        if first {
            self.yesButton.setTitle("Enable Notifications", forState: UIControlState.Normal)
            self.locationManager = OneShotLocationManager()
            self.locationManager!.fetchWithCompletion {location, error in
                // fetch location or an error
                if let loc = location {
                    self.appDelegate.locCurrent = loc
                } else if let err = error {
                    print(err.localizedDescription)
                }
                self.locationManager = nil
            }
            
            self.first = false
        }
        else {
            self.appDelegate.initializeNotificationServices()
            
            let alert = UIAlertController(title: "Hey!", message: "Would you like a quick tour of Knot? (you can also find this in the account screen later)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Naw", style: .Default, handler: { (alertAction) -> Void in
                //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                //self.presentViewController(vc, animated: true, completion: nil)
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Sure!", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("tutorial") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func skipButton(sender: AnyObject) {
        if first {
            self.yesButton.setTitle("Enable Notifications", forState: UIControlState.Normal)
            self.first = false
        }
        else {
            let alert = UIAlertController(title: "Hey!", message: "Would you like a quick tour of Knot? (you can also find this in the account screen later)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Naw", style: .Default, handler: { (alertAction) -> Void in
                //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                //self.presentViewController(vc, animated: true, completion: nil)
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Sure!", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("tutorial") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    

}