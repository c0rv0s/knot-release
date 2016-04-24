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

class AccountView: UIViewController, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    let picker = UIImagePickerController()
    
    var whichPhoto = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        
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
                        self.profPic.image = UIImage(data: data!)
                    }
                    if bucket == "header-photos" {
                        self.headerPhoto.image = UIImage(data: data!)!
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
    
    @IBAction func changeProfPic(sender: AnyObject) {
        whichPhoto = "profile"
        showCamera()
    }
    
    
    @IBAction func changeHeaderPhoto(sender: AnyObject) {
        whichPhoto = "header"
        showCamera()
    }
    
    func showCamera() {
        let alert = UIAlertController(title: "Select Option:", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (alertAction) -> Void in
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                self.picker.allowsEditing = false
                self.picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.picker.cameraCaptureMode = .Photo
                self.picker.modalPresentationStyle = .FullScreen
                self.presentViewController(self.picker,
                    animated: true,
                    completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Photos", style: .Default, handler: { (alertAction) -> Void in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.picker.modalPresentationStyle = .FullScreen
            self.presentViewController(self.picker,
                animated: true,
                completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            picker.modalPresentationStyle = .FullScreen
            presentViewController(picker,
                                  animated: true,
                                  completion: nil)
        }

    }
    
    //MARK: - Delegates
    //What to do when the picker returns with a photo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        print("picker returns")
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        var picOne : UIImage!
        var bucket : String!
        if whichPhoto == "profile" {
            picOne = self.resizeImage(self.cropToSquare(image: chosenImage))
            bucket = "user-prof-photos"
        }
        else {
            picOne = self.resizeImage(chosenImage)
            bucket = "header-photos"
        }
        //myImageView.contentMode = .ScaleAspectFit //3
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        print("resize image")
        
        
            //upload pic
            let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let dataOne = UIImageJPEGRepresentation(picOne, 0.5)
            dataOne!.writeToURL(testFileURL1, atomically: true)
            uploadRequest1.bucket = bucket
            uploadRequest1.key = self.appDelegate.cognitoId
            uploadRequest1.body = testFileURL1
            let task1 = transferManager.upload(uploadRequest1)
            task1.continueWithBlock { (task: AWSTask!) -> AnyObject! in
                if task1.error != nil {
                    print("Error: \(task1.error)")
                } else {
                    //self.preUploadComplete = true
                    print("photo one done")
                }
                return nil
            }
            //done uploading
        print("download done, image set")
        
        if whichPhoto == "profile" {
            self.profPic.image = picOne
        }
        else {
            self.headerPhoto.image = picOne
        }
        
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true,
                                      completion: nil)
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        var actualHeight = CGFloat(image.size.height)
        var actualWidth = CGFloat(image.size.width)
        var maxHeight = CGFloat(400.0)
        var maxWidth = CGFloat(400.00)
        var imgRatio = CGFloat(actualWidth/actualHeight)
        var maxRatio = CGFloat(maxWidth/maxHeight)
        var compressionQuality = CGFloat(0.95)//40 percent compressio
        
        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        //[image drawInRect:rect];
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return UIImage(data:imageData!)!
        
    }

    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
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