//
//  File.swift
//  Knot
//
//  Created by Nathan Mueller on 2/12/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK
import CoreLocation

class SignUp: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let picker = UIImagePickerController()
    
    @IBOutlet weak var profPicView: UIImageView!
    //@IBOutlet weak var genderLabel: UITextField!
    //@IBOutlet weak var ageLabel: UITextField!
    //@IBOutlet weak var emailLabel: UITextField!
    @IBOutlet weak var firstNameLabel: UITextField!
    @IBOutlet weak var lastNameLabel: UITextField!
    
    @IBOutlet weak var doneButton: UIButton!
    
    //@IBOutlet weak var disclaimerTwo: UILabel!
    //@IBOutlet weak var disclaimerOne: UILabel!
    var signUp = true
    
    //location
    var locationManager: OneShotLocationManager!
    
    override func viewDidLoad() {
        print("view loaded, signup Bool value is: ")
        print(signUp)
        super.viewDidLoad()
        //self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        
        self.picker.delegate = self
        /*
        emailLabel.delegate = self;
        genderLabel.delegate = self;
        ageLabel.delegate = self;
        firstNameLabel.delegate = self;
        lastNameLabel.delegate = self
        
        emailLabel.hidden = true
        ageLabel.hidden  = true
        genderLabel.hidden = true
        disclaimerOne.hidden = true
        disclaimerTwo.hidden = true
 
        //age label
        let border = CALayer()
        
        border.borderColor = UIColor.darkGrayColor().CGColor
        border.frame = CGRect(x: 0, y: ageLabel.frame.size.height - width, width:  ageLabel.frame.size.width, height: ageLabel.frame.size.height)
        
        border.borderWidth = width
        ageLabel.layer.addSublayer(border)
        ageLabel.layer.masksToBounds = true
 
        //first name
        let width = CGFloat(2.0)
        let borderName = CALayer()
        borderName.borderColor = UIColor.darkGrayColor().CGColor
        borderName.frame = CGRect(x: 0, y: firstNameLabel.frame.size.height - width, width:  firstNameLabel.frame.size.width, height: firstNameLabel.frame.size.height)
        
        borderName.borderWidth = width
        firstNameLabel.layer.addSublayer(borderName)
        firstNameLabel.layer.masksToBounds = true
        
        //last name
        let borderLast = CALayer()
        borderLast.borderColor = UIColor.darkGrayColor().CGColor
        borderLast.frame = CGRect(x: 0, y: lastNameLabel.frame.size.height - width, width:  lastNameLabel.frame.size.width, height: lastNameLabel.frame.size.height)
        
        borderLast.borderWidth = width
        lastNameLabel.layer.addSublayer(borderLast)
        lastNameLabel.layer.masksToBounds = true
*/
        self.returnUserData()
    }
        
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                
                if (result.valueForKey("name") != nil) {
                    let userName : NSString = result.valueForKey("name") as! NSString
                    let fullNameArr = userName.componentsSeparatedByString(" ")
                    
                    var firstName: String = fullNameArr[0]
                    var lastName: String = fullNameArr[1]
                    
                    print("User Name is: \(userName)")
                    
                    self.firstNameLabel.text = "\(firstName)"
                    self.lastNameLabel.text = "\(lastName)"
                }
                /*
                if (result.valueForKey("age_range") != nil) {
                    let birthday : NSNumber = result.valueForKey("age_range")!.objectForKey("min") as! NSNumber
                    print("User age is: \(birthday)")
                    self.ageLabel.text = "\(birthday)"
                }
                
                if (result.valueForKey("gender") != nil) {
                    let gender : NSString = result.valueForKey("gender") as! NSString
                    print("User gender is: \(gender)")
                    self.genderLabel.text = "\(gender)"
                }
                
                if (result.valueForKey("email") != nil) {
                    let userEmail : NSString = result.valueForKey("email") as! NSString
                    print("User email is: \(userEmail)")
                    self.emailLabel.text = "\(userEmail)"
                }
                */
                if let url = NSURL(string: result.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                    if let data = NSData(contentsOfURL: url){
                        var profilePicture = UIImage(data: data)
                        
                        self.profPicView.image = profilePicture
                    }
                }
                
            }
        })
        
    }
    
    func fillFields() {
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")
        if (dataset.stringForKey("firstName") != nil) {
            self.firstNameLabel.text = dataset.stringForKey("firstName")
        }
        if (dataset.stringForKey("lastName") != nil) {
            self.lastNameLabel.text = dataset.stringForKey("lastName")
        }
        if (dataset.stringForKey("SBID") != nil) {
            print(dataset.stringForKey("SBID"))
        }
        /*
        if (dataset.stringForKey("email") != nil) {
            self.emailLabel.text = dataset.stringForKey("email")
        }
        if (dataset.stringForKey("age") != nil) {
            self.ageLabel.text = dataset.stringForKey("age")
        }
        if (dataset.stringForKey("gender") != nil) {
            self.genderLabel.text = dataset.stringForKey("gender")
        }
*/
    }

    @IBAction func doneButtonAction(sender: AnyObject) {
        
        //ask if user would like to see listings from friends
        let alert = UIAlertController(title: "Would you like to see listings from your Facebook friends?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alertAction) -> Void in
            self.finishProf(true)
        }))
        alert.addAction(UIAlertAction(title: "Not Now", style: .Default, handler: { (alertAction) -> Void in
            self.finishProf(false)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func finishProf(friends: Bool) {
        //check that all fields are filled
        if (self.firstNameLabel.text == "" || self.lastNameLabel.text == "" /*|| self.genderLabel.text == "" || self.ageLabel.text == "" || emailLabel.text == ""*/ ) {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            SwiftSpinner.show("Completing Profile")
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            //upload prof pic
            let picOne = self.resizeImage(self.cropToSquare(image: self.profPicView.image!))
            //upload pic
            let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let dataOne = UIImageJPEGRepresentation(picOne, 0.5)
            dataOne!.writeToURL(testFileURL1, atomically: true)
            uploadRequest1.bucket = "user-prof-photos"
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
            
            //upload profile
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("profileInfo")
            
            dataset.setString(self.firstNameLabel.text, forKey:"firstName")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset.setString(self.lastNameLabel.text, forKey:"lastName")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString("true", forKey:"firstUse")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString("5", forKey:"rating")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            dataset.setString(String(friends), forKey:"SeeFriends")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            /*
             dataset.setString(self.ageLabel.text, forKey:"age")
             dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
             return nil
             }
             dataset.setString(self.genderLabel.text, forKey:"gender")
             dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
             return nil
             }
             dataset.setString(self.emailLabel.text, forKey:"email")
             dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
             return nil
             }
             */
            /*
             print("Now lets take a look at the SendBird ID")
             //set SendBird ID
             //if let currentSBID = dataset.stringForKey("SBID") {
             let value = dataset.stringForKey("SBID")
             if value != nil {
             print("dataset shows: " + value)
             
             }
             else {
             dataset.setString(SendBird.deviceUniqueID(), forKey:"SBID")
             dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
             return nil
             }
             print("new SBID uploaded")
             print(SendBird.deviceUniqueID())
             }*/
            
            if self.signUp {
                self.appDelegate.loggedIn = true
                
                dataset.setString("true", forKey:"firstUse")
                dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                    return nil
                }
                
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("StepZero") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
                
                
            }
            else {
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("AccountView") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
            
            self.appDelegate.mixpanel!.track?(
                "SignUp",
                properties: ["userID": self.appDelegate.cognitoId!]
            )
            
            SwiftSpinner.hide()
            
        }
    }
    
    @IBAction func changePicButton(sender: AnyObject) {
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
        //myImageView.contentMode = .ScaleAspectFit //3
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        print("resize image")
        let picOne = self.resizeImage(self.cropToSquare(image: chosenImage))
        
        //upload pic
        let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        let dataOne = UIImageJPEGRepresentation(picOne, 0.5)
        dataOne!.writeToURL(testFileURL1, atomically: true)
        uploadRequest1.bucket = "user-prof-photos"
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
        self.profPicView.image = picOne
        
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true,
                                      completion: nil)
    }

    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    func resizeImage(image: UIImage) -> UIImage {
        var actualHeight = CGFloat(image.size.height)
        var actualWidth = CGFloat(image.size.width)
        var maxHeight = CGFloat(300.0)
        var maxWidth = CGFloat(500.00)
        var imgRatio = CGFloat(actualWidth/actualHeight)
        var maxRatio = CGFloat(maxWidth/maxHeight)
        var compressionQuality = CGFloat(0.75)//40 percent compressio
        
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

    
}
