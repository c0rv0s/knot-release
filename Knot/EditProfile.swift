//
//  EditProfile.swift
//  Knot
//
//  Created by Nathan Mueller on 2/19/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class EditProfile: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var firstNameLabel: UITextField!
    
    @IBOutlet weak var lastNameLabel: UITextField!
    
    @IBOutlet weak var ageLabel: UITextField!
    
    @IBOutlet weak var genderLabel: UITextField!
    
    @IBOutlet weak var emailLabel: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    let picker = UIImagePickerController()
    
    
    var whichPhoto = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        self.fillFields()
    }
    
    @IBAction func saveAction(sender: AnyObject) {
        if (self.firstNameLabel.text == "" || self.lastNameLabel.text == "" || self.genderLabel.text == "" || self.ageLabel.text == "" || emailLabel.text == "" ) {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            //upload profile
            let syncClient = AWSCognito.defaultCognito()
            var dataset = syncClient.openOrCreateDataset("profileInfo")
            dataset.setString(self.firstNameLabel.text, forKey:"firstName")
            dataset.setString(self.lastNameLabel.text, forKey:"lastName")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
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
            
            dataset = syncClient.openOrCreateDataset("completed-quests")
            dataset.setString("true", forKey:"finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset.setString("true", forKey:"finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }
            
            dataset = syncClient.openOrCreateDataset("active-quests")
            dataset.removeObjectForKey("finish-profile")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                if task.cancelled {
                    // Task cancelled.
                    SwiftSpinner.hide()
                    
                } else if task.error != nil {
                    SwiftSpinner.hide()
                    // Error while executing task
                    
                } else {
                    SwiftSpinner.hide()
                    // Task succeeded. The data was saved in the sync store.
                    
                    
                }
                return nil
            }
            
            //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            //self.presentViewController(vc, animated: true, completion: nil)
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
            
        }
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
        if (dataset.stringForKey("email") != nil) {
            self.emailLabel.text = dataset.stringForKey("email")
        }
        if (dataset.stringForKey("age") != nil) {
            self.ageLabel.text = dataset.stringForKey("age")
        }
        if (dataset.stringForKey("gender") != nil) {
            self.genderLabel.text = dataset.stringForKey("gender")
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
}