//
//  EditProfile.swift
//  Knot
//
//  Created by Nathan Mueller on 2/19/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class EditProfile: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var firstNameLabel: UITextField!
    
    @IBOutlet weak var lastNameLabel: UITextField!
    
    @IBOutlet weak var ageLabel: UITextField!
    
    @IBOutlet weak var genderLabel: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fillFields()
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if (self.firstNameLabel.text == "" || self.lastNameLabel.text == "" || self.genderLabel.text == "" || self.ageLabel.text == "" || emailLabel.text == "" ) {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //upload profile
            let syncClient = AWSCognito.defaultCognito()
            var dataset = syncClient.openOrCreateDataset("profileInfo")
            dataset.setString(self.firstNameLabel.text, forKey:"firstName")
            dataset.setString(self.lastNameLabel.text, forKey:"lastName")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString(self.ageLabel.text, forKey:"age")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString(self.genderLabel.text, forKey:"gender")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString(self.emailLabel.text, forKey:"email")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset = syncClient.openOrCreateDataset("completed-quests")
            dataset.setString("true", forKey:"finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset.setString("true", forKey:"finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset = syncClient.openOrCreateDataset("active-quests")
            dataset.removeObjectForKey("finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                if task.cancelled {
                    // Task cancelled.
                    SwiftSpinner.hide()
                    
                } else if task.error != nil {
                    SwiftSpinner.hide()
                    // Error while executing task
                    
                } else {
                    SwiftSpinner.hide()
                    // Task succeeded. The data was saved in the sync store.
                    
                    
                }
                return nil
            }
            
            //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            //self.presentViewController(vc, animated: true, completion: nil)
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
    }
    
    func fillFields() {
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")
        if (dataset.stringForKey("firstName") != nil) {
            self.firstNameLabel.text = dataset.stringForKey("firstName")
        }
        if (dataset.stringForKey("lastName") != nil) {
            self.lastNameLabel.text = dataset.stringForKey("lastName")
        }
        if (dataset.stringForKey("email") != nil) {
            self.emailLabel.text = dataset.stringForKey("email")
        }
        if (dataset.stringForKey("age") != nil) {
            self.ageLabel.text = dataset.stringForKey("age")
        }
        if (dataset.stringForKey("gender") != nil) {
            self.genderLabel.text = dataset.stringForKey("gender")
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}