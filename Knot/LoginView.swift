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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        let token = FBSDKAccessToken.currentAccessToken().tokenString
        appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
        
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
        }
        
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
                // Do work
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
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
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
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