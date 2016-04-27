//
//  ListingUpload.swift
//  Knot
//
//  Created by Nathan Mueller on 4/26/16.
//  Copyright © 2016 Knot App. All rights reserved.
//
/*
import Foundation

//experimental class to modularize listing uploads since they can be performed from the main screen or the auth screen.
public class ListingUpload {
    
    
    func insertItem(uniqueID: String, auth: Bool) -> BFTask! {
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
        
        if auth {
            item.authenticated = true
        }
        
        //parse to get just the first decimal point and two characters after
        var priceString = ""
        let priceArray = self.priceField.text!.componentsSeparatedByString(".")
        if priceArray[0] == "" {
            priceString = "0"
        }
        else {
            priceString = priceArray[0]
        }
        for i in priceString.characters {
            if (i == "0" || i == "1" || i == "2" || i == "3" || i == "4" || i == "5" || i == "6" || i == "7" || i == "8" || i == "9"){}
            else {
                priceString = String(priceString.characters.dropFirst())
            }
        }
        for i in priceString.characters {
            if i == "0" {
                priceString = String(priceString.characters.dropFirst())
            }
            else {
                break
            }
        }
        print("priceString")
        print(priceString)
        
        
        item.name  = self.nameField.text!
        item.ID   = uniqueID
        item.price   = priceString
        item.location =  locString
        item.time  = dateString
        item.sold = "false"
        item.seller = cognitoID!
        item.sellerFBID = self.fbID
        item.descriptionKnot = self.descriptionField.text
        item.category = categoryField.text!
        item.condition = conditionField.text!
        item.sellerSBID = self.SBID
        item.numberOfPics = self.photoNum
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }

    
    func wrapUpSubmission(succ1: Int, succ2: Int, succ3: Int) {
        SwiftSpinner.hide()
        if /*succ1 == 2 || succ2 == 2 || succ3 == 2 ||*/ self.preUploadComplete == false {
            let alert = UIAlertController(title: "Uh Oh", message: "Something went wrong, shake to contact support or try again", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        print("Upload successful")
        var alertString = ""
        if authenticated {
            alertString = "Congratulations on authenticating your item! This will be listed in the Knot Store in a few moments."
        }
        else {
            alertString = "This will be listed in the Knot Store in a few moments."
        }
        let alert = UIAlertController(title: "Success", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .Default, handler: { (alertAction) -> Void in
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        self.appDelegate.mixpanel!.track?(
            "Item Upload",
            properties: ["userID": self.appDelegate.cognitoId!, "item": self.uniqueID]
        )
        
        self.appDelegate.mixpanel!.people.increment(
            [ "Listings": 1]
        )
    }
    
    func loadData(auth: Bool) {
        // Do whatever you want
        UIApplication.sharedApplication().statusBarHidden = false
        SwiftSpinner.show("Uploading \(self.nameField.text!)")
        
        /*
         self.appDelegate.mixpanel!.track(
         "New Upload",
         properties: ["userID": self.cognitoID, "itemID": self.uniqueID]
         )
         */
        
        self.insertItem(uniqueID, auth: auth).continueWithBlock({
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
            if task1.error != nil {
                print("Error: \(task1.error)")
            } else {
                print("thumbnail added")
                self.wrapUpSubmission(success1, succ2: success2, succ3: success3)
                
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
        
        print("Load data")
    }
    

}
 
 */