//
//  File.swift
//  Knot
//
//  Created by Nathan Mueller on 2/12/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK
import CoreLocation

class SignUp: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var genderLabel: UITextField!
    @IBOutlet weak var ageLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var disclaimerTwo: UILabel!
    @IBOutlet weak var disclaimerOne: UILabel!
    var signUp = true
    
    //location
    var locationManager: OneShotLocationManager!

    
    override func viewDidLoad() {
        print("view loaded, signup Bool value is: ")
        print(signUp)
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        
        emailLabel.delegate = self;
        genderLabel.delegate = self;
        ageLabel.delegate = self;
        firstNameLabel.delegate = self;
        lastNameLabel.delegate = self
        
        emailLabel.hidden = true
        ageLabel.hidden  = true
        genderLabel.hidden = true
        disclaimerOne.hidden = true
        disclaimerTwo.hidden = true
        
        //age label
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: ageLabel.frame.size.height - width, width:  ageLabel.frame.size.width, height: ageLabel.frame.size.height)
        
        border.borderWidth = width
        ageLabel.layer.addSublayer(border)
        ageLabel.layer.masksToBounds = true
        
        //first name
        let borderName = CALayer()
        borderName.borderColor = UIColor.darkGrayColor().CGColor
        borderName.frame = CGRect(x: 0, y: firstNameLabel.frame.size.height - width, width:  firstNameLabel.frame.size.width, height: firstNameLabel.frame.size.height)
        
        borderName.borderWidth = width
        firstNameLabel.layer.addSublayer(borderName)
        firstNameLabel.layer.masksToBounds = true
        
        //last name
        let borderLName = CALayer()
        borderLName.borderColor = UIColor.darkGrayColor().CGColor
        borderLName.frame = CGRect(x: 0, y: lastNameLabel.frame.size.height - width, width:  lastNameLabel.frame.size.width, height: lastNameLabel.frame.size.height)
        
        borderLName.borderWidth = width
        lastNameLabel.layer.addSublayer(border)
        lastNameLabel.layer.masksToBounds = true

        self.returnUserData()
    }
        
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                
                if (result.valueForKey("name") != nil) {
                    let userName : NSString = result.valueForKey("name") as! NSString
                    let fullNameArr = userName.componentsSeparatedByString(" ")
                    
                    var firstName: String = fullNameArr[0]
                    var lastName: String = fullNameArr[1]
                    
                    print("User Name is: \(userName)")
                    
                    self.firstNameLabel.text = "\(firstName)"
                    self.lastNameLabel.text = "\(lastName)"
                }
                /*
                if (result.valueForKey("age_range") != nil) {
                    let birthday : NSNumber = result.valueForKey("age_range")!.objectForKey("min") as! NSNumber
                    print("User age is: \(birthday)")
                    self.ageLabel.text = "\(birthday)"
                }
                
                if (result.valueForKey("gender") != nil) {
                    let gender : NSString = result.valueForKey("gender") as! NSString
                    print("User gender is: \(gender)")
                    self.genderLabel.text = "\(gender)"
                }
                
                if (result.valueForKey("email") != nil) {
                    let userEmail : NSString = result.valueForKey("email") as! NSString
                    print("User email is: \(userEmail)")
                    self.emailLabel.text = "\(userEmail)"
                }
                */
                if let url = NSURL(string: result.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                    if let data = NSData(contentsOfURL: url){
                        var profilePicture = UIImage(data: data)
                        
                        self.profPicView.image = profilePicture
                    }
                }
                
            }
        })
        
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
        if (dataset.stringForKey("SBID") != nil) {
            print(dataset.stringForKey("lastName"))
        }
        /*
        if (dataset.stringForKey("email") != nil) {
            self.emailLabel.text = dataset.stringForKey("email")
        }
        if (dataset.stringForKey("age") != nil) {
            self.ageLabel.text = dataset.stringForKey("age")
        }
        if (dataset.stringForKey("gender") != nil) {
            self.genderLabel.text = dataset.stringForKey("gender")
        }
*/
    }

    @IBAction func doneButtonAction(sender: AnyObject) {
        
        if (self.firstNameLabel.text == "" || self.lastNameLabel.text == "" /*|| self.genderLabel.text == "" || self.ageLabel.text == "" || emailLabel.text == ""*/ ) {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            SwiftSpinner.show("Completing Profile")
            //upload profile
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("profileInfo")
            
            dataset.setString(self.firstNameLabel.text, forKey:"firstName")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset.setString(self.lastNameLabel.text, forKey:"lastName")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString("true", forKey:"firstUse")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            /*
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
*/
            /*
            print("Now lets take a look at the SendBird ID")
            //set SendBird ID
            //if let currentSBID = dataset.stringForKey("SBID") {
            let value = dataset.stringForKey("SBID")
            if value != nil {
                print("dataset shows: " + value)

            }
            else {
                dataset.setString(SendBird.deviceUniqueID(), forKey:"SBID")
                dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                    return nil
                }
                print("new SBID uploaded")
                print(SendBird.deviceUniqueID())
            }*/

            if self.signUp {
                
                self.appDelegate.loggedIn = true
                //calculate distance
                //remember to switch this b4 release
                locationManager = OneShotLocationManager()
                locationManager!.fetchWithCompletion {location, error in
                    // fetch location or an error
                    if let loc = location {
                        self.appDelegate.locCurrent = loc
                    } else if let err = error {
                        print(err.localizedDescription)
                    }
                    self.locationManager = nil
                }
                
                self.appDelegate.initializeNotificationServices()
                
                
                dataset.setString("true", forKey:"firstUse")
                dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                    return nil
                }
                
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
            else {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("AccountView") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
            self.appDelegate.mixpanel!.track?(
                "SignUp",
                properties: ["userID": self.appDelegate.cognitoId!]
            )
            
            SwiftSpinner.hide()
            
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
    
    private func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.view.bounds
        // take into account the status bar
        updatedFrame.size.height += 20
        var layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
