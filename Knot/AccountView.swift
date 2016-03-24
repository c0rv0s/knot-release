//
//  AccountView.swift
//  Knot
//
//  Created by Nathan Mueller on 1/19/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import MessageUI

class AccountView: UIViewController, MFMailComposeViewControllerDelegate  {

    @IBOutlet weak var profCompleteLabel: UILabel!
    @IBOutlet weak var completeProfileAlert: UIImageView!
    @IBOutlet weak var completeProfile: UIButton!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    var dict : NSDictionary!
    
    @IBOutlet weak var supportButon: UIButton!
    @IBOutlet weak var editProfile: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var tutButton: UIButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var legalButton: UIButton!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.completeProfile.hidden = true
        self.completeProfileAlert.hidden = true
        
        //user id stuff
        if self.appDelegate.loggedIn == false {
            let alert = UIAlertController(title:"Attention", message: "You need to sign in to access these features", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Never Mind", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Sign In", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
                    self.presentViewController(alert, animated: true, completion: nil)
        }
        self.returnUserDataForProf()
        
        //fetch quest status
        let syncClient = AWSCognito.defaultCognito()
        /*
        var dataset = syncClient.openOrCreateDataset("completed-quests")
        let value = dataset.stringForKey("finish-profile")
        if (value == nil) {
            dataset = syncClient.openOrCreateDataset("active-quests")
            dataset.setString("true", forKey:"finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            self.completeProfile.hidden = false
            self.completeProfileAlert.hidden = false
            self.profCompleteLabel.text = "Profile Incomplete"
        }*/
        
        //check for account info
        var dataset = syncClient.openOrCreateDataset("profileInfo")
        let value2 = dataset.stringForKey("age")
        if (value2 == nil) {
            self.completeProfile.hidden = false
            self.completeProfileAlert.hidden = false
            self.profCompleteLabel.text = "Profile Incomplete"
        }

    }
    
    func returnUserDataForProf() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                self.Name.text = userName as String
                
                if let url = NSURL(string: result.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                    if let data = NSData(contentsOfURL: url){
                        var profilePicture = UIImage(data: data)
                        
                        self.profPic.image = profilePicture

                        //self.imageFadeIn(self.profPic, image: profilePicture!)
                        
                    }
                }

            }
        })
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
            }
        })
    }
    
    func imageFadeIn(imageView: UIImageView, image: UIImage) {
        
        let secondImageView = UIImageView(image: image)
        secondImageView.frame = imageView.frame
        secondImageView.alpha = 0.0
        
        view.insertSubview(secondImageView, aboveSubview: imageView)
        
        UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 1.0
            }, completion: {_ in
                imageView.image = secondImageView.image
                secondImageView.removeFromSuperview()
        })
        
    }

}