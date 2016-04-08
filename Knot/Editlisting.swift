//
//  editlisting.swift
//  Knot
//
//  Created by Nathan Mueller on 3/10/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import UIKit
import CoreLocation

class EditListing: UIViewController, UITextFieldDelegate,
UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoOne: UIImageView!
    @IBOutlet weak var photoTwo: UIImageView!
    @IBOutlet weak var photoThree: UIImageView!
    
    var picOne: UIImage!
    var picTwo: UIImage!
    var picThree: UIImage!
    var thumbnail: UIImage!
    
    @IBOutlet weak var changePhotoOne: UIButton!
    
    @IBOutlet weak var changePhotoTwo: UIButton!
    
    @IBOutlet weak var changePhotoThree: UIButton!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var roundedDescrip: RoundedCornersView!
    
    @IBOutlet weak var conditionField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var descripText: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    
    var activeField: UITextField?
    
    var photoNum : Int = 1
    var photoChanged = false
    let picker = UIImagePickerController()
    
    var DetailItem: ListItem!
    
    //var pic : UIImage!

    var conditionOption = ["New", "Manufacturer refurbished", "Seller refurbished", "Used", "For parts or not working"]
    var categoryOption = ["Art and Antiques", "Baby and Child", "Books, Movies and Music", "Games and Consoles", "Electronics", "Cameras and Photo", "Fashion and Accessories", "Sport and Leisure", "Cars and Motor", "Furniture", "Appliances", "Services", "Other"]
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var preUploadComplete = false
    
    //location
    var locString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = CGSize(width:375, height: 800)
        self.roundedDescrip.layer.borderWidth = 1;
        self.roundedDescrip.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor
        
        
        picker.delegate = self
        // Do any additional setup after loading the view, typically from a nib
        photoTwo.hidden = true
        photoThree.hidden = true
        changePhotoTwo.hidden = true
        changePhotoThree.hidden = true
        
        nameField.delegate = self;
        
        let categoryView = UIPickerView()
        categoryView.tag = 1
        categoryView.delegate = self
        categoryField.inputView = categoryView
        
        let conditionView = UIPickerView()
        conditionView.tag = 2
        conditionView.delegate = self
        conditionField.inputView = conditionView

        
        priceField.delegate = self
        priceField.keyboardType = UIKeyboardType.NumbersAndPunctuation
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.nameField.text = DetailItem.name
        self.priceField.text = DetailItem.price
        self.descripText.text = DetailItem.descriptionKnot
        self.categoryField.text = DetailItem.category
        self.conditionField.text = DetailItem.condition
        self.photoOne.image = self.resizeImage(picOne)

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.preUploadComplete = false
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return categoryOption.count
        }
        else {
            return conditionOption.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        if pickerView.tag == 1 {
            return categoryOption[row]
        }
        if pickerView.tag == 2 {
            return conditionOption[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        if pickerView.tag == 1 {
            categoryField.text = categoryOption[row]
        }
        if pickerView.tag == 2 {
            conditionField.text = conditionOption[row]
        }
    }
    
    //keyboard
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        
        if keyboardSize.height == offset.height {
            if self.view.frame.origin.y == 0 {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    self.view.frame.origin.y -= keyboardSize.height
                })
            }
        } else {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y += keyboardSize.height - offset.height
            })
        }
        print(self.view.frame.origin.y)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
    }
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification)
    {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField
        {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin))
            {
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = false
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeField = nil
    }
    //end keyboard
    
    @IBAction func addphoto1(sender: AnyObject) {
        photoNum = 1
        self.showCamera()
    }
    @IBAction func addphoto2(sender: AnyObject) {
        photoNum = 2
        self.showCamera()
    }
    @IBAction func addphoto3(sender: AnyObject) {
        photoNum = 3
        self.showCamera()
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
    func imagePickerController(
        picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]){
            let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
            //myImageView.contentMode = .ScaleAspectFit //3
            if photoNum == 1 {
                self.photoChanged = true
                picOne = chosenImage
                thumbnail = self.resizeImage(chosenImage)
                /*
                //upload thumbnail
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
                let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                let dataThumb = UIImageJPEGRepresentation(thumbnail, 0.5)
                dataThumb!.writeToURL(testFileURL1, atomically: true)
                uploadRequest1.bucket = "knotcomplexthumbnails"
                uploadRequest1.key = self.uniqueID
                uploadRequest1.body = testFileURL1
                let task1 = transferManager.upload(uploadRequest1)
                task1.continueWithBlock { (task: AWSTask!) -> AnyObject! in
                if task.error != nil {
                print("Error: \(task.error)")
                } else {
                print("thumbnail added")
                }
                return nil
                }
                //done uploading
                */
                //upload pic
                let transferManager = AWSS3TransferManager.defaultS3TransferManager()
                let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
                let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                let dataOne = UIImageJPEGRepresentation(picOne, 0.5)
                dataOne!.writeToURL(testFileURL1, atomically: true)
                uploadRequest1.bucket = "knotcompleximages"
                uploadRequest1.key = self.DetailItem.ID
                uploadRequest1.body = testFileURL1
                let task1 = transferManager.upload(uploadRequest1)
                task1.continueWithBlock { (task: AWSTask!) -> AnyObject! in
                    if task.error != nil {
                        print("Error: \(task.error)")
                    } else {
                        self.preUploadComplete = true
                    }
                    return nil
                }
                //done uploading
                
                
                self.photoOne.image = self.cropToSquare(image: chosenImage)
                //addphoto2.hidden = false
                self.changePhotoOne.setTitle("Change", forState: .Normal)
                //one = true
                //picTwoView.image = UIImage(named: "grey")
            }
            if photoNum == 2 {
                self.photoTwo.image = self.cropToSquare(image: chosenImage)
                //addphoto2.hidden = false
                self.changePhotoTwo.setTitle("Change", forState: .Normal)
                //two = true
                //picTwoView.image = UIImage(named: "grey")
            }
            if photoNum == 3 {
                self.photoThree.image = self.cropToSquare(image: chosenImage)
                //addphoto2.hidden = false
                self.changePhotoThree.setTitle("Change", forState: .Normal)
                //one = true
                //picTwoView.image = UIImage(named: "grey")
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
        var maxHeight = CGFloat(300.0)
        var maxWidth = CGFloat(500.00)
        var imgRatio = CGFloat(actualWidth/actualHeight)
        var maxRatio = CGFloat(maxWidth/maxHeight)
        var compressionQuality = CGFloat(0.40)//40 percent compression
        
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
    
    @IBAction func doneAction(sender: AnyObject) {
        
        if (self.nameField.text == "" || self.priceField.text == "" || self.descripText.text == "" || self.categoryField.text == "Category" || self.conditionField.text == "Item Condition") {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            self.insertItem(self.DetailItem.ID).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
            
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
            if photoChanged {
                //
                //
                var success1 = 0
                var success2 = 0
                var success3 = 0
                
                //upload thumbnail
                SwiftSpinner.show("Finishing Upload")
                self.thumbnail = self.resizeImage(self.picOne)
                let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
                let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
                let dataThumb = UIImageJPEGRepresentation(thumbnail, 0.5)
                dataThumb!.writeToURL(testFileURL1, atomically: true)
                uploadRequest1.bucket = "knotcomplexthumbnails"
                uploadRequest1.key = self.DetailItem.ID
                uploadRequest1.body = testFileURL1
                let task1 = transferManager.upload(uploadRequest1)
                task1.continueWithBlock { (task: AWSTask!) -> AnyObject! in
                    if task.error != nil {
                        print("Error: \(task.error)")
                    } else {
                        print("thumbnail added")
                        
                        repeat {
                            var delayInSeconds = 1.0;
                            var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
                            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                                if self.preUploadComplete {
                                    //self.wrapUpSubmission(success1, succ2: success2, succ3: success3)
                                    //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                                    //self.presentViewController(vc, animated: true, completion: nil)
                                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
                                    self.presentViewController(vc, animated: true, completion: nil)
                                }
                            }
                        }
                            while(self.preUploadComplete == false)
                    }
                    return nil
                }
                //done uploading
            
            }
            //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            //self.presentViewController(vc, animated: true, completion: nil)
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
        
    }
    
    func insertItem(uniqueID: String) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        let item = ListItem()
        
        item.name  = self.nameField.text!
        item.ID   = DetailItem.ID
        item.price   = self.priceField.text!
        item.location =  DetailItem.location
        item.time  = DetailItem.time
        item.sold = DetailItem.sold
        item.seller = DetailItem.seller
        item.sellerFBID = DetailItem.sellerFBID
        item.descriptionKnot = self.descripText.text
        item.category = categoryField.text!
        item.condition = conditionField.text!
        item.numberOfPics = photoNum
        item.sellerSBID = DetailItem.sellerSBID
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }
    
    @IBOutlet weak var cancelEdit: UIButton!
    
    @IBAction func cancelEdit(sender: AnyObject) {
        //self.tabBarController?.tabBar.hidden = false
        //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
        //self.presentViewController(vc, animated: true, completion: nil)
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }

}