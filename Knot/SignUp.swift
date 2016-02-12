//
//  File.swift
//  Knot
//
//  Created by Nathan Mueller on 2/12/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit

class SignUp: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["user_friends"]
        loginView.delegate = self
        
    }
    
    // Facebook Delegate Methods
    
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
    
    @IBAction func TermsOfService(sender: AnyObject) {
        if let url = NSURL(string: "http://www.knotcomplex.com/privacy") {
            UIApplication.sharedApplication().openURL(url)
        }
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
