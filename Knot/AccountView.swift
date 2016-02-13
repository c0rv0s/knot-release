//
//  AccountView.swift
//  Knot
//
//  Created by Nathan Mueller on 1/19/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class AccountView: UIViewController, FBSDKLoginButtonDelegate  {

    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    var dict : NSDictionary!
    
    @IBOutlet weak var tutButton: UIButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tutButton.layer.borderWidth = 1;
        self.tutButton.layer.borderColor = UIColor(red: 0.46, green: 0.44, blue: 0.40, alpha: 1.0).CGColor
        
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        loginView.readPermissions = ["user_friends"]
        loginView.delegate = self
        
        self.returnUserDataForProf()
    }
    
    func returnUserDataForProf() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), email"])
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
                    }
                }

            }
        })
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

    @IBAction func viewTutorial(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("tutorial") as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    

}