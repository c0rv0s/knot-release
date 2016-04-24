//
//  AccountView.swift
//  Knot
//
//  Created by Nathan Mueller on 1/19/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import MessageUI
import MobileCoreServices

class AccountView: UIViewController, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var headerPhoto: UIImageView!
    @IBOutlet weak var changeProfPic: UIButton!
    //user analytics
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var numSoldLabel: UILabel!
    //var flappyScore = ""
    
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
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var legalButton: UIButton!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    // Float rating view params
    @IBOutlet var floatRatingView: FloatRatingView!
    var starRating = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.completeProfile.hidden = true
        self.completeProfileAlert.hidden = true
        
        self.floatRatingView.emptyImage = UIImage(named: "empty-star")
        self.floatRatingView.fullImage = UIImage(named: "full-star")
        self.floatRatingView.editable = false
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        //user id stuff
        if self.appDelegate.loggedIn == false {
            let alert = UIAlertController(title:"Attention", message: "You need to sign in to access these features", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Never Mind", style: .Default, handler: { (alertAction) -> Void in
                //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                //self.presentViewController(vc, animated: true, completion: nil)
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
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
        
        //store revenue data for user
        if let value3 = dataset.stringForKey("revenue") {
            self.revenueLabel.text = value3
        }
        
        if let value4 = dataset.stringForKey("gross") {
            self.numSoldLabel.text = "$ " + value4
        }

    }
    
    func returnUserDataForProf() {
        //get name
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")
        if (dataset.stringForKey("firstName") != nil) {
            let fName = dataset.stringForKey("firstName")
            if (dataset.stringForKey("lastName") != nil) {
                let lName = dataset.stringForKey("lastName")
                self.Name.text = fName + " " + lName
            }
        }
        if (dataset.stringForKey("rating") != nil) {
            self.starRating = Int(dataset.stringForKey("rating"))!
            self.floatRatingView.rating = Float(starRating)
        }
        /*
        if (dataset.stringForKey("flappyScore") != nil) {
            self.flappyScore = dataset.stringForKey("flappyScore")
        }*/
        
        downloadImage(appDelegate.cognitoId!, bucket: "user-prof-photos")
        downloadImage(appDelegate.cognitoId!, bucket: "header-photos")
    }
    
    func downloadImage(key: String, bucket: String) {
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        let S3BucketName: String = bucket
        let S3DownloadKeyName: String = key
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.downloadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                //self.progressView.progress = progress
                //   self.statusLabel.text = "Downloading..."
                NSLog("Progress is: %f",progress)
            })
        }
        
        completionHandler = { (task, location, data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    NSLog("Failed with error")
                    NSLog("Error: %@",error!);
                }
                else{
                    if bucket == "user-prof-photos" {
                        self.imageFadeIn(self.profPic, image: UIImage(data: data!)!)
                        //self.profPic.image = UIImage(data: data!)
                    }
                    if bucket == "header-photos" {
                        self.imageFadeIn(self.headerPhoto, image: UIImage(data: data!)!)
                        //self.headerPhoto.image = UIImage(data: data!)
                    }
                }
            })
            
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility.downloadToURL(nil, bucket: S3BucketName, key: S3DownloadKeyName, expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
            }
            if let exception = task.exception {
                NSLog("Exception: %@",exception.description);
            }
            if let _ = task.result {
                
            }
            return nil;
        }
        
    }
    
    func imageFadeIn(imageView: UIImageView, image: UIImage) {
        
        let secondImageView = UIImageView(image: image)
        secondImageView.frame = imageView.frame
        secondImageView.alpha = 0.0
        
        view.insertSubview(secondImageView, aboveSubview: imageView)
        
        UIView.animateWithDuration(0.33, delay: 0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 1.0
            }, completion: {_ in
                imageView.image = secondImageView.image
                secondImageView.removeFromSuperview()
        })
        
    }

}