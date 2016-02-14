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
                self.presentViewController(vc, animated: false, completion: nil)
            }
            else {
                print("user logged in")
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
                //fetch profile
                let syncClient = AWSCognito.defaultCognito()
                let dataset = syncClient.openOrCreateDataset("profileInfo")
                let value = dataset.stringForKey("gender")
                if (value == nil) {
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                    self.presentViewController(vc, animated: false, completion: nil)
                }
                else {
                    print("profile found!")
                    let APP_ID: String = "6D1F1F00-D8E0-4574-A738-4BDB61AF0411"
                    
                    SendBird.initAppId(APP_ID, withDeviceId: SendBird.deviceUniqueID())
                }
            }
        }
        else {
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("launchScreen") as! UIViewController
            self.presentViewController(vc, animated: false, completion: nil)
        }
    }
}