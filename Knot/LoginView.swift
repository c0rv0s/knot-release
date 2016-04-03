//
//  File.swift
//  Knot
//
//  Created by Nathan Mueller on 11/24/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

import Foundation
import UIKit

class LoginView: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var buttonView: UIView!
    
    //fb data
    var fbname = ""
    var fbemail = ""
    var fbday = ""
    var fbgender = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden=true
        self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        //self.loginbutton.layer.borderWidth = 1;
        //self.loginbutton.layer.borderColor = UIColor.whiteColor().CGColor
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = buttonView.center
        loginView.readPermissions = ["user_friends"]
        loginView.delegate = self

    }
    
    @IBAction func SeeTerms(sender: AnyObject) {
        if let url = NSURL(string: "http://www.knotcomplex.com/Terms.html") {
            UIApplication.sharedApplication().openURL(url)
        }
    }

    @IBAction func SeePrivacy(sender: AnyObject) {
        if let url = NSURL(string: "http://www.knotcomplex.com/Privacy.html") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        self.appDelegate.loggedIn = true
        
        let token = FBSDKAccessToken.currentAccessToken().tokenString
        appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
        
        // Retrieve your Amazon Cognito ID
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            
            if (task.error != nil) {
                print("CognitoID Error: " + task.error!.localizedDescription)
                
            } else {
                // the task result will contain the identity id
                self.appDelegate.cognitoId = task.result as! String
                print("Cognito ID: ")
                print (self.appDelegate.cognitoId)
            }
            return nil
        }
        
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
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
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
    }

    @IBAction func howUseFB(sender: AnyObject) {
        let alert = UIAlertController(title: "How we use Facebook", message: "Knot uses your Facebook profile to seamlessly populate your Seller Profile and verify your account. This provides extra security, promotes safety and ease of use.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
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