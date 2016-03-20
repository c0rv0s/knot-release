//
//  HomeTabBarController.swift
//  Knot
//
//  Created by Nathan Mueller on 12/11/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK

class HomeTabBarController: UITabBarController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //var startApp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Retrieve your Amazon Cognito ID
        if FBSDKAccessToken.currentAccessToken() != nil {
            print("user logged in")
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
            appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            
                if (task.error != nil) {
                    print("CognitoID Error: " + task.error!.localizedDescription)
                
                }
                else {
                    self.appDelegate.cognitoId = task.result as! String
                    print("login was a success, consider putting stuff here")
                }
                return nil
            }
        }
        
        if appDelegate.startApp {
            print("checking fb token status")
            //if self.appDelegate.loggedIn {
            if FBSDKAccessToken.currentAccessToken() != nil {
                print("user logged in")
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
                
                /*
                // Retrieve your Amazon Cognito ID
                appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                    
                    if (task.error != nil) {
                        print("CognitoID Error: " + task.error!.localizedDescription)
                        
                    }
                    else {
                        self.appDelegate.cognitoId = task.result as! String
                        print("login was a success, consider puttign stuff here")
                    }
                    return nil
                }*/
                /*
                print("Now lets take a look at the SendBird ID")
                //set SendBird ID
                let syncClient = AWSCognito.defaultCognito()
                let dataset = syncClient.openOrCreateDataset("profileInfo")
                if (dataset.stringForKey("SBID") == nil) {
                    dataset.setString(SendBird.deviceUniqueID(), forKey:"SBID")
                    dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                        return nil
                    }
                    print("new SBID uploaded")
                }
                else {
                    print("dataset shows: " + dataset.stringForKey("SBID"))
                }*/


            }
            //this handle unauth logins
            else {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                self.presentViewController(vc, animated: false, completion: nil)
            }
        }
        else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("launchScreen") as! UIViewController
            self.presentViewController(vc, animated: false, completion: nil)
        }

        
    }
}