//
//  File.swift
//  Knot
//
//  Created by Nathan Mueller on 11/24/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

import Foundation
import UIKit

class LoginView: UIViewController{
    
    
    @IBOutlet weak var loginbutton: UIButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var locationManager: OneShotLocationManager?
    @IBOutlet weak var signupbuttin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden=true
        self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        self.signupbuttin.layer.borderWidth = 1;
        self.signupbuttin.layer.borderColor = UIColor.whiteColor().CGColor
        self.loginbutton.layer.borderWidth = 1;
        self.loginbutton.layer.borderColor = UIColor.whiteColor().CGColor
        
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // User is already logged in, do work such as go to next view controller.
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager = OneShotLocationManager()
        locationManager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
            } else if let err = error {
                print(err.localizedDescription)
            }
            self.locationManager = nil
        }
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