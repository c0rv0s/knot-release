//
//  NewItemView.swift
//  Knot
//
//  Created by Nathan Mueller on 11/23/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

import UIKit
import CoreLocation

class NewItemView: UIViewController, UITextFieldDelegate,
UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var picOneView: UIImageView!
    @IBOutlet weak var picTwoView: UIImageView!
    @IBOutlet weak var picThreeView: UIImageView!
    
    var activeField: UITextField?
    
    var picOne: UIImage!
    var picTwo: UIImage!
    var picThree: UIImage!
    var thumbnail: UIImage!
    
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    
    @IBOutlet weak var addphoto1: UIButton!
    @IBOutlet weak var addphoto2: UIButton!
    @IBOutlet weak var addphoto3: UIButton!
    
    @IBOutlet weak var lengthField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var conditionField: UITextField!
    
    
    @IBOutlet weak var descripFieldView: RoundedCornersView!
    
    var photoNum : Int = 1
    let picker = UIImagePickerController()
    var fbID = "error"
    var SBID = ""
    
    var one = false
    var two = false
    var three = false
    
    var timeHoursInt = 288
    var hours = [3,5,12,24,72,120,168, 288]
    var lengthOption = ["3 Hours", "5 Hours", "12 Hours", "24 Hours", "3 Days", "5 Days", "7 Days", "12 Days"]
    var conditionOption = ["New", "Manufacturer refurbished", "Seller refurbished", "Used", "For parts or not working"]
    var categoryOption = ["Art and Antiques", "Baby and Child", "Books, Movies and Music", "Games and Consoles", "Electronics", "Cameras and Photo", "Fashion and Accessories", "Sport and Leisure", "Cars and Motor", "Furniture", "Appliances", "Services", "Other"]
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var uniqueID = ""
    
    var preUploadComplete = false
    
    //location
    var locString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        //more testing
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
        }
*/
        
        //user id stuff
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    let dict = result as! NSDictionary
                    self.fbID = dict.objectForKey("id") as! String
                }
            })
            
            self.scrollView.contentSize = CGSize(width:375, height: 800)
            self.tabBarController?.tabBar.hidden = true
            
            self.descripFieldView.layer.borderWidth = 1;
            self.descripFieldView.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor
            
            
            picker.delegate = self
            // Do any additional setup after loading the view, typically from a nib
            addphoto2.hidden = true
            addphoto3.hidden = true
            self.uniqueID = randomStringWithLength(16) as String
            
            nameField.delegate = self;
            
            let lengthView = UIPickerView()
            lengthView.tag = 0
            lengthView.delegate = self
            lengthField.inputView = lengthView
            
            let categoryView = UIPickerView()
            categoryView.tag = 1
            categoryView.delegate = self
            categoryField.inputView = categoryView
            
            let conditionView = UIPickerView()
            conditionView.tag = 2
            conditionView.delegate = self
            conditionField.inputView = conditionView
            
            //let location = appDelegate.locCurrent
            
            
            priceField.delegate = self
            priceField.keyboardType = UIKeyboardType.NumbersAndPunctuation
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
            
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
            view.addGestureRecognizer(tap)
            
            //fetch sbid
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("profileInfo")
            var value = dataset.stringForKey("SBID")
            if (value == nil) {
                //no action necessary
            }
            else {
                self.SBID = value
            }
            if let value2 = dataset.stringForKey("firstUse") {
                if value == "true" {
                    let alert = UIAlertController(title: "Head's Up", message: "There are a few rules involved with posting items to Knot, no drugs, weapons, or explicit material is allowed, you will be banned. \nPlease take a moment to get a really good picture, studies show these sell better :)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Got it!", style: .Default, handler: { (alertAction) -> Void in
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                
                    dataset.setString("false", forKey:"firstUse")
                    dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                        return nil
                    }
                }
            }
            
            
            self.scrollView.directionalLockEnabled = true
        }
        
        else {
            let alert = UIAlertController(title:"Attention", message: "You need to sign in to access these features", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Never Mind", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Sign In", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }

        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        self.preUploadComplete = false
    }
    
    func makeScrambledLocation(location: CLLocation) {
        var newLat = location.coordinate.latitude
        var newLon = location.coordinate.longitude
        
        var lower : UInt32 = 1
        var upper : UInt32 = 5
        let randomNumber = Double(arc4random_uniform(upper - lower) + lower)
        
        lower = 0
        upper = 2
        let randomNumber2 = arc4random_uniform(upper - lower) + lower
        let randomNumber3 = arc4random_uniform(upper - lower) + lower
        
        if randomNumber2  == 0 {
            newLat = newLat - Double(randomNumber / 1000)
        }
        else {
            newLat = newLat + Double(randomNumber / 1000)
        }
        
        if randomNumber3 == 0 {
            newLon = newLon + Double(randomNumber / 1000)
        }
        else {
            newLon = newLon -  Double(randomNumber / 1000)        }
        
        var construct = String(newLat) + " "
        construct += String(newLon)
        self.locString = construct
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        return randomString
    }
    
    func insertItem(uniqueID: String) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        /***CONVERT FROM NSDate to String ****/
        print(timeHoursInt)
        let currentDate = NSDate()
        //get over hours
        self.calcTimeHoursInt()
        let overDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: timeHoursInt, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(overDate!)
        
        self.makeScrambledLocation(self.appDelegate.locCurrent)
        
        
        // Create a record in a dataset and synchronize with the server
        // Retrieve your Amazon Cognito ID
        var cognitoID = appDelegate.cognitoId
        /*
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                cognitoID = task.result as! String
            }
            return nil
        }*/
        
        let item = ListItem()
        
        item.name  = self.nameField.text!
        item.ID   = uniqueID
        item.price   = self.priceField.text!
        item.location =  locString
        item.time  = dateString
        item.sold = "false"
        item.seller = cognitoID!
        item.sellerFBID = self.fbID
        item.descriptionKnot = self.descriptionField.text
        item.category = categoryField.text!
        item.condition = conditionField.text!
        item.numberOfPics = photoNum
        item.sellerSBID = self.SBID
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }
    
    func calcTimeHoursInt() {
        //[1,3,5,12,24,72,120,168]
        if lengthField.text == lengthOption[0] {
            self.timeHoursInt = hours[0]
        }
        if lengthField.text == lengthOption[1] {
            self.timeHoursInt = hours[1]
        }
        if lengthField.text == lengthOption[2] {
            self.timeHoursInt = hours[2]
        }
        if lengthField.text == lengthOption[3] {
            self.timeHoursInt = hours[3]
        }
        if lengthField.text == lengthOption[4] {
            self.timeHoursInt = hours[4]
        }
        if lengthField.text == lengthOption[5] {
            self.timeHoursInt = hours[5]
        }
        if lengthField.text == lengthOption[6] {
            self.timeHoursInt = hours[6]
        }
        print(timeHoursInt)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return lengthOption.count
        }
        if pickerView.tag == 1 {
            return categoryOption.count
        }
        else {
            return conditionOption.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            //print(row)
            //timeHoursInt = hours[row]
            return lengthOption[row]
        }
        if pickerView.tag == 1 {
            return categoryOption[row]
        }
        if pickerView.tag == 2 {
            return conditionOption[row]
        }
        return ""
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            lengthField.text = lengthOption[row]
        }
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
                uploadRequest1.key = self.uniqueID
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
                
                
                picOneView.image = self.cropToSquare(image: chosenImage)
                //addphoto2.hidden = false
                addphoto1.setTitle("Change", forState: .Normal)
                one = true
                picTwoView.image = UIImage(named: "grey")
            }
            if photoNum == 2 {
                picTwo = chosenImage
                picTwoView.image = chosenImage
                addphoto3.hidden = false
                addphoto2.setTitle("Change", forState: .Normal)
                two = true
                picThreeView.image = UIImage(named: "grey")
            }
            if photoNum == 3 {
                picThree = chosenImage
                picThreeView.image = chosenImage
                addphoto3.setTitle("Change", forState: .Normal)
                three = true
            }
            dismissViewControllerAnimated(true, completion: nil) //5
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true,
            completion: nil)
    }
    
    @IBAction func submit(sender: AnyObject) {
        if (self.nameField.text == "" || self.priceField.text == "" || self.descriptionField.text == "..." || self.categoryField.text == "Category" || self.lengthField.text == "Length of Listing" || self.conditionField.text == "Item Condition" || self.picOne == nil) {
            let alert = UIAlertController(title: "Attention", message: "Please enter the missing values.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            SwiftSpinner.show("Uploading \(self.nameField.text!)")
            
            self.insertItem(uniqueID).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
            print("hello")
            //upload image
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            
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
            uploadRequest1.key = self.uniqueID
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
                                self.wrapUpSubmission(success1, succ2: success2, succ3: success3)
                            }
                        }
                    }
                    while(self.preUploadComplete == false)
                }
                return nil
            }
            //done uploading
            
            /*
            if one {
            print("one is one")
            let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let dataOne = UIImageJPEGRepresentation(picOne, 0.5)
            dataOne!.writeToURL(testFileURL1, atomically: true)
            uploadRequest1.bucket = "knotcompleximages"
            uploadRequest1.key = self.uniqueID
            uploadRequest1.body = testFileURL1
            let task1 = transferManager.upload(uploadRequest1)
            task1.continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
            print("Error: \(task.error)")
            success1 = 2
            } else {
            success1 = 1
            self.wrapUpSubmission(success1, succ2: success2, succ3: success3)
            //these two are a mess, fix before implementing
            /*
            if self.two {
            print("two is on")
            let testFileURL2 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest2 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let imageDataTwo = self.picTwo.mediumQualityJPEGNSData
            let dataTwo = UIImageJPEGRepresentation(UIImage(data: imageDataTwo)!, 0.5)
            dataTwo!.writeToURL(testFileURL2, atomically: true)
            uploadRequest2.bucket = "knotcompleximage2"
            uploadRequest2.key = self.uniqueID
            uploadRequest2.body = testFileURL2
            let task2 = transferManager.upload(uploadRequest2)
            task2.continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
            print("Error: \(task.error)")
            success2 = 2
            } else {
            success2 = 1
            if self.three {
            print("three is on")
            let testFileURL3 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest3 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let imageDataThree = self.picThree.mediumQualityJPEGNSData
            let dataThree = UIImageJPEGRepresentation(UIImage(data: imageDataThree)!, 0.5)
            dataThree!.writeToURL(testFileURL3, atomically: true)
            uploadRequest3.bucket = "knotcompleximage3"
            uploadRequest3.key = self.uniqueID
            uploadRequest3.body = testFileURL3
            let task3 = transferManager.upload(uploadRequest3)
            task3.continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if task.error != nil {
            print("Error: \(task.error)")
            success3 = 2
            }
            else {
            print("Upload successful")
            
            }
            return nil
            }
            
            }
            }
            return nil
            }
            
            }*/
            }
            return nil
            }
            }*/
        }
    }
    
    func wrapUpSubmission(succ1: Int, succ2: Int, succ3: Int) {
        SwiftSpinner.hide()
        if succ1 == 2 || succ2 == 2 || succ3 == 2 || self.preUploadComplete == false {
            let alert = UIAlertController(title: "Uh Oh", message: "Something went wrong, shake to contact support or try again", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        print("Upload successful")
        let alert = UIAlertController(title: "Success", message: "Your upload has completed. It should be visible in the store feed in a few minutes.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .Default, handler: { (alertAction) -> Void in
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
            self.presentViewController(vc, animated: true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //end upload and submissions
    @IBAction func cancelListing(sender: AnyObject) {
        self.tabBarController?.tabBar.hidden = false
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "returnHome") {
            let viewController:HomeTabBarController = segue!.destinationViewController as! HomeTabBarController
            //viewController.startApp = true
        }
    }
}