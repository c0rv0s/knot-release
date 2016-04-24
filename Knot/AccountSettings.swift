//
//  AccountSettings.swift
//  Knot
//
//  Created by Nathan Mueller on 3/5/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import MessageUI

class AccountSettings: UIViewController, FBSDKLoginButtonDelegate,  MFMailComposeViewControllerDelegate  {
    
    @IBOutlet weak var supportButon: UIButton!
    @IBOutlet weak var editProfile: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var tutButton: UIButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        self.tutButton.layer.borderWidth = 1;
        self.tutButton.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor

        self.legalButton.layer.borderWidth = 1;
        self.legalButton.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor
        
        self.editProfile.layer.borderWidth = 1;
        self.editProfile.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor
        
        self.supportButon.layer.borderWidth = 1;
        self.supportButon.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor
*/
        self.editProfile.hidden = true
        self.tutButton.hidden = true
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = buttonView.center
        loginView.readPermissions = ["user_friends"]
        loginView.delegate = self
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        let token = FBSDKAccessToken.currentAccessToken().tokenString
        appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
        
        /*
        // Retrieve your Amazon Cognito ID
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            
            if (task.error != nil) {
                print("CognitoID Error: " + task.error!.localizedDescription)
                
            } else {
                // the task result will contain the identity id
                self.appDelegate.cognitoId = task.result
                print("Cognito ID: ")
                print (self.appDelegate.cognitoId)
            }
            return nil
        }*/
        
        //fetch profile
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")
        let value = dataset.stringForKey("gender")
        if (value == nil || value.rangeOfString("male") == nil) {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("SignUp") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else {
            print("facebook authentication successful!")
            //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            //self.presentViewController(vc, animated: true, completion: nil)
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        
        //error handling
        if ((error) != nil)
        {
            // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if result.grantedPermissions.contains("email")
            {
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
        self.presentViewController(vc, animated: false, completion: nil)
    }
    
    @IBAction func ViewTerms(sender: AnyObject) {
        if let url = NSURL(string: "http://www.knotcomplex.com/Terms.html") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func ViewPrivacy(sender: AnyObject) {
        if let url = NSURL(string: "http://www.knotcomplex.com/Privacy.html") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func viewTutorial(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("tutorial") as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func contactSupport(sender: AnyObject) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@knotcomplex.com"])
            
            var body = ""
            mail.setMessageBody(body, isHTML: false)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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