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

class SignUp: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var profPicView: UIImageView!
    @IBOutlet weak var genderLabel: UITextField!
    @IBOutlet weak var ageLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var nameLabel: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var signUp = true
    
    override func viewDidLoad() {
        print("view loaded, signup Bool value is: ")
        print(signUp)
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        
        
        self.emailLabel.delegate = self;
        self.genderLabel.delegate = self;
        self.ageLabel.delegate = self;
        self.nameLabel.delegate = self;
        
        self.returnUserData()
    }
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email, age_range, gender"])
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
                    print("User Name is: \(userName)")
                    self.nameLabel.text = "\(userName)"
                }
                
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
                
                if let url = NSURL(string: result.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                    if let data = NSData(contentsOfURL: url){
                        var profilePicture = UIImage(data: data)
                        
                        self.profPicView.image = profilePicture
                    }
                }
                
            }
        })
        
    }

    @IBAction func doneButtonAction(sender: AnyObject) {
        
        if (self.nameLabel.text == "Name" || self.genderLabel.text == "Gender" || self.ageLabel.text == "Birthday" || self.emailLabel.text == "Enter your email" || emailLabel.text == "" ) {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //upload profile
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("profileInfo")
            dataset.setString(self.nameLabel.text, forKey:"name")
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
            
            if self.signUp {
                let alert = UIAlertController(title: "Hey!", message: "Would you like a quick tour of Knot? (you can also find this in the account screen later)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Naw", style: .Default, handler: { (alertAction) -> Void in
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
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
