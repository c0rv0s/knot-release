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
        
        if appDelegate.startApp {
            print("checking fb token status")
            if (FBSDKAccessToken.currentAccessToken() == nil) {
                print("user not logged in")
            
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
            else {
                print("user logged in")
                let token = FBSDKAccessToken.currentAccessToken().tokenString
                appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
            
                // Retrieve your Amazon Cognito ID
                appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                
                    if (task.error != nil) {
                        print("CognitoID Error: " + task.error!.localizedDescription)
                    
                    }
                    else {
                        
                        // the task result will contain the identity id
                        self.appDelegate.cognitoId = task.result
                        print("Cognito ID: ")
                        print (self.appDelegate.cognitoId)
                        //fetch profile
                        let syncClient = AWSCognito.defaultCognito()
                        let dataset = syncClient.openOrCreateDataset("profileInfo")
                        let value = dataset.stringForKey("gender")
                        if (value == nil || value.rangeOfString("male") == nil) {
                            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                            self.presentViewController(vc, animated: false, completion: nil)
                        }
                        else {
                            
                            print("Now lets take a look at the SendBird ID")
                            print(dataset.stringForKey("SBID"))
                            //set SendBird ID
                            if (dataset.stringForKey("SBID") == nil) {
                                dataset.setString(SendBird.deviceUniqueID(), forKey:"SBID")
                                dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                                    return nil
                                }
                                print("new SBID uploaded")
                            }
                            else {
                                print("dataset shows: " + dataset.stringForKey("SBID"))
                            }
                            print("profile found!")
                        }   
                    }
                    return nil
                }

            }
        }
        else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("launchScreen") as! UIViewController
            self.presentViewController(vc, animated: false, completion: nil)
        }
    }
}