//
//  ItemDetail.swift
//  Knot
//
//  Created by Nathan Mueller on 11/15/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import MessageUI
import SendBirdSDK

class ItemDetail: UIViewController, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, MKMapViewDelegate {
    //stars
    var sellerStars : Int!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    var lastEvaluatedKey:[NSObject : AnyObject]!
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var multiplePics: UIButton!
    //@IBOutlet weak var pageControl: UIPageControl!
    //@IBOutlet weak var imageScroll: UIScrollView!
    //@IBOutlet var profPicGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var itemPic: UIImageView!
    @IBOutlet weak var reportSlashEdit: UIBarButtonItem!
    @IBOutlet weak var savelabel: UILabel!
    @IBOutlet weak var favButton: DOFavoriteButton!

    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []

    
   @IBOutlet weak var alternatingButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var descripText: UITextView!

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var profPic: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var sellerName: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var DetailItem: ListItem!
    
    var pic : UIImage!
    var croppedPic : UIImage!
    var picTwo : UIImage!
    var picThree : UIImage!
    
    var name : String = "Text"
    var price : String = "Text"
    var time: String = "Time"
    var IDNum: String = ""
    var itemSeller: String = ""
    var location: String = ""
    var sold: String = ""
    var cognitoID: String = ""
    var fbID: String = ""
    var descript: String = ""
    var condition: String = ""
    var category: String = ""
    var numPics: Int = 1
    var sellerSBID: String = ""
    
    var selleremail: String = ""
    
    var owned: Bool = false
    
    //timer variables
    var secondsUntil: Int = 100
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let dateFormatter = NSDateFormatter()
    var latitude :Double = 0.0
    var longitude: Double = 0.0
    var locCurrent: CLLocation!
    
    //var to make sure that the first image appears in multi-image view
    var imgDL = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.name = self.DetailItem.name
        self.price = self.DetailItem.price
        self.time = self.DetailItem.time
        self.IDNum = self.DetailItem.ID
        self.itemSeller = self.DetailItem.seller
        self.location = self.DetailItem.location
        self.sold = self.DetailItem.sold
        self.fbID = self.DetailItem.sellerFBID
        self.descript = self.DetailItem.descriptionKnot
        self.condition = self.DetailItem.condition
        self.category = self.DetailItem.category
        self.numPics = self.DetailItem.numberOfPics
        self.sellerSBID = self.DetailItem.sellerSBID
        
        if self.DetailItem.seller == self.appDelegate.cognitoId {
            self.owned = true
        }
        
        self.pic = self.cropToSquare(image: UIImage(named: "placeholder")!)
        
        self.scrollView.contentSize = CGSize(width:375, height: 1031)
        
        //grab pictures
        self.downloadImage(IDNum, photoNum: 1)
        
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        self.locCurrent = appDelegate.locCurrent
        
        favButton.addTarget(self, action: Selector("tapped:"), forControlEvents: .TouchUpInside)
        //fetch favorite status
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("favorites")
        let value = dataset.stringForKey(self.IDNum)
        if (value == nil) {
            //no action necessary
        }
        else {
            self.favButton.select()
            self.savelabel.text = "Saved!"
            
        }

        
        
        
        //set button state
        if self.owned {
            self.alternatingButton.setTitle("Mark As Sold or Delete", forState: .Normal)
            self.reportSlashEdit.title = "Edit"
        }
        else {
            self.alternatingButton.setTitle("Contact", forState: .Normal)
        }
        
        if self.sold != "false" {
            self.reportSlashEdit.title = ""
        }
        
        //set labels
        descripText.text = descript
        descripText.editable = false

        self.cognitoID = appDelegate.cognitoId!
        
        //do some more setup stuff
        self.returnUserData()
        self.updateLocation()
 
        nameLabel.text = name
        priceLabel.text = "$" + price
        categoryLabel.text = self.DetailItem.category
        conditionLabel.text = self.condition
        
        /*
        if DetailItem.authenticated {
            self.thumbImage.image = UIImage(named: "thumbprint")
        }
 */
        //switch for authentication. this will line up which badge to use
        switch DetailItem.authenticated {
        case 0:
            break
        case 1:
            self.thumbImage.image = UIImage(named: "thumbprint")
        case 2:
            self.thumbImage.image = UIImage(named: "thumbprint")
        default:
            break
        }
 
        //stars
        self.floatRatingView.emptyImage = UIImage(named: "empty-star")
        self.floatRatingView.fullImage = UIImage(named: "full-star")
        self.floatRatingView.editable = false
        
        self.secondsUntil = secondsFrom(NSDate(), endDate: dateFormatter.dateFromString(time)!)
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    func returnUserData() {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: fbID, parameters: ["fields": "id, name, picture.type(large)"])
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
                self.sellerName.text = userName as String
                /*
                if let url = NSURL(string: result.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                    if let data = NSData(contentsOfURL: url){
                        var profilePicture = UIImage(data: data)
                        
                        self.profPic.image = profilePicture
                    }
                }*/
                
            }
        })
            
            var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
            
            let S3BucketName: String = "user-prof-photos"
            let S3DownloadKeyName: String = itemSeller
            
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
                        //if bucket == "user-prof-photos" {
                            self.profPic.image = UIImage(data: data!)
                       // }
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
        
        self.downloadStar()
        
    }
    
    func downloadStar() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        print("finna fetch those ratings")
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBScanExpression()
        queryExpression.exclusiveStartKey = self.lastEvaluatedKey
        
        dynamoDBObjectMapper.scan(CurrentStars.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if task.result != nil {
                let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                for item in paginatedOutput.items as! [CurrentStars] {
                    if item.userID == self.itemSeller {
                        self.sellerStars = item.stars
                        self.floatRatingView.rating = Float(self.sellerStars)
                    }
                }
                
                self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
            }
            if ((task.error) != nil) {
                print("Error: \(task.error)")
            }
            return nil
        })
    }

    func downloadImage(key: String, photoNum: Int){
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        //downloading image
        var S3BucketName : String!
        if photoNum == 1 {
            S3BucketName = "knotcompleximages"
        }
        if photoNum == 2 {
            S3BucketName = "knotcompleximage2"
        }
        if photoNum == 3 {
            S3BucketName = "knotcompleximage3"
        }
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
                    //   self.statusLabel.text = "Failed"
                }
                    /*
                    else if(self.progressView.progress != 1.0) {
                    //    self.statusLabel.text = "Failed"
                    NSLog("Error: Failed - Likely due to invalid region / filename")
                    }   */
                else{
                    var newPic = UIImage(data: data!)!
                    var cropNewPic = self.cropToSquare(image: UIImage(data: data!)!)
                    if photoNum == 1 {
                        self.pic = newPic
                        self.itemPic.image = cropNewPic
                        self.croppedPic = cropNewPic
                        self.imgDL = true
                    }
                    if photoNum == 2 {
                        self.picTwo = newPic
                    }
                    if photoNum == 3 {
                        self.picThree = newPic
                    }
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility.downloadToURL(nil, bucket: S3BucketName, key: S3DownloadKeyName, expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
                //  self.statusLabel.text = "Failed"
            }
            if let exception = task.exception {
                NSLog("Exception: %@",exception.description);
                //  self.statusLabel.text = "Failed"
            }
            if let _ = task.result {
                //    self.statusLabel.text = "Starting Download"
                //NSLog("Download Starting!")
                // Do something with uploadTask.
            }
            return nil;
        }
        
    }

    
    func update() {
        
        self.setTextColor(secondsUntil)

        if(secondsUntil > 0)
        {
            if sold == "true" {
                timeLabel.text = "Sold!"
                timeLabel.textColor = UIColor.greenColor()
            }
            
            else {

                timeLabel.text = printSecondsToDaysHoursMinutesSeconds(secondsUntil--)
            }
        }

        else {
            updateSoldStatus("ended")
            timeLabel.text = "Ended"
            //self.alternatingButton.hidden = true
        }

    }
    
    func setTextColor(seconds: Int) {
        if(seconds < 43200 && seconds >= 0)
        {
            timeLabel.textColor = UIColor.redColor()
        }
        if(seconds >= 43200)
        {
            timeLabel.textColor = UIColor.blackColor()
        }
    }
    
    func secondsToDaysHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printSecondsToDaysHoursMinutesSeconds (seconds:Int) -> String {
        let (d, h, m, s) = secondsToDaysHoursMinutesSeconds (seconds)
        if m < 10 {
            if s < 10 {
                return "\(d) Days, \(h):0\(m):0\(s) left"
            }
            return "\(d) Days, \(h):0\(m):\(s) left"
        }
        if s < 10 {
            return "\(d) Days, \(h):\(m):0\(s) left"
        }
        return "\(d) Days, \(h):\(m):\(s) left"
    }
    
    func secondsFrom(startDate:NSDate, endDate:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: startDate, toDate: endDate, options: []).second
    }

    func updateLocation()
    {
        let coordinatesArr = self.location.characters.split{$0 == " "}.map(String.init)
        print(self.latitude = Double(coordinatesArr[0])!)
        print(self.longitude = Double(coordinatesArr[1])!)
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 500
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 3.75, regionRadius * 3.75)
            map.setRegion(coordinateRegion, animated: true)
        }
        let location = CLLocation(latitude: latitude, longitude: longitude)

        centerMapOnLocation(location)
        
        //find the distance
        let distanceBetween = initialLocation.distanceFromLocation(self.locCurrent) * 0.000621371
        var stringFormat = String(format: "%.0f", distanceBetween + 1)
        if stringFormat == "1" {
            self.distanceLabel.text = "About " + stringFormat + " mile away"
        }
        else {
            self.distanceLabel.text = "About " + stringFormat + " miles away"
        }
        
        //now print out the address
        var address = ""
        var streetHolder = ""
        var cityHolder = ""
        
        self.map.addOverlay(MKCircle(centerCoordinate: location.coordinate, radius: 900))
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let overlay = overlay as? MKCircle
            let circleRenderer = MKCircleRenderer(circle: overlay!)
            let blue = UIColor(red: 56.1/255, green: 119.85/255, blue: 229.5/255, alpha: 0.25)
            circleRenderer.fillColor = blue
            return circleRenderer
        
    }
    
    //change item sold status or delete
    func updateSoldStatus(type: String) {
        if type == "deleted" {
            self.performDelete(self.DetailItem).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB delete succeeded")
                    let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
                    self.presentViewController(vc, animated: true, completion: nil)
                }
                
                return nil;
            })
        }
        var hashValue: AWSDynamoDBAttributeValue = AWSDynamoDBAttributeValue()
        hashValue.S = self.IDNum
        var otherValue: AWSDynamoDBAttributeValue = AWSDynamoDBAttributeValue()
        otherValue.S = self.time
        var updatedValue: AWSDynamoDBAttributeValue = AWSDynamoDBAttributeValue()
        updatedValue.S = type
        
        var updateInput: AWSDynamoDBUpdateItemInput = AWSDynamoDBUpdateItemInput()
        updateInput.tableName = "knot-listings"
        updateInput.key = ["ID": hashValue, "time": otherValue]
        var valueUpdate: AWSDynamoDBAttributeValueUpdate = AWSDynamoDBAttributeValueUpdate()
        valueUpdate.value = updatedValue
        valueUpdate.action = AWSDynamoDBAttributeAction.Put
        updateInput.attributeUpdates = ["sold": valueUpdate]
        updateInput.returnValues = AWSDynamoDBReturnValue.UpdatedNew
        
        self.sold = type
        AWSDynamoDB.defaultDynamoDB().updateItem(updateInput).waitUntilFinished()
    }
    
    //deletion helper method
    func performDelete(item: ListItem) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        let task = mapper.remove(item)
        
        print("item removed")
        return BFTask(forCompletionOfAllTasks: [task])
    }
    
    //relist item
    func updateTimeStatus() {
        let alert = UIAlertController(title: "How Long?", message: "Select a relist time length:", preferredStyle: UIAlertControllerStyle.Alert)
        var length = 72
        alert.addAction(UIAlertAction(title: "Three Days", style: .Default, handler: { (alertAction) -> Void in
            self.insertItem(length).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        }))
        alert.addAction(UIAlertAction(title: "Five Days", style: .Default, handler: { (alertAction) -> Void in
            length = 120
            self.insertItem(length).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        }))
        alert.addAction(UIAlertAction(title: "Twelve Days", style: .Default, handler: { (alertAction) -> Void in
            length = 288
            self.insertItem(length).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        }))
        alert.addAction(UIAlertAction(title: "Eighteen Days", style: .Default, handler: { (alertAction) -> Void in
            length = 432
            self.insertItem(length).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //relist helper method
    
    //relist helper method
    func insertItem(length: Int) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        /***CONVERT FROM NSDate to String ****/
        let currentDate = NSDate()

        let overDate = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Hour, value: length, toDate: currentDate, options: NSCalendarOptions.init(rawValue: 0))
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(overDate!)
        
        var item = self.DetailItem
        item.time  = dateString

        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "editListing") {
            let viewController:EditListing = segue!.destinationViewController as! EditListing
            
            viewController.picOne = self.itemPic.image
            
            viewController.DetailItem = self.DetailItem
        }
        if (segue!.identifier == "contactSegue") {
            let viewController:Messaging = segue!.destinationViewController as! Messaging
            
            viewController.viewMode = kMessagingViewMode
            viewController.messagingTargetUserId = sellerSBID
            viewController.contacted = true
        }
        if (segue!.identifier == "ShowPageSegue") {
            let viewController:pageController = segue!.destinationViewController as! pageController
            
            viewController.DetailItem = self.DetailItem
            if self.imgDL {
                viewController.pic = self.pic
            }
            else {
                viewController.needToDL = true
            }
        }
        
    }

    //this is some extra code that could be used for blocking users
                /*
                let syncClient = AWSCognito.defaultCognito()
                let dataset = syncClient.openOrCreateDataset("blockedUsers")
                //let value = dataset.stringForKey(self.itemSeller)
                
                self.appDelegate.mixpanel!.track(
                    "User Blocked",
                    properties: ["userID": self.cognitoID, "blockedID": self.itemSeller, "itemID": self.IDNum]
                )
                
                dataset.setString("true", forKey:self.itemSeller)
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
 */
    
    @IBAction func reportOrEdit(sender: AnyObject) {
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
        
        if self.owned {
            self.performSegueWithIdentifier("editListing", sender: self)
        }
        else {
            var why = "Cancel"
            let alert = UIAlertController(title: "Report Item", message: "Please select an option: ", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Violence", style: .Default, handler: { (alertAction) -> Void in
                why = "Violence"
                self.sendEmail(why)
            }))
            alert.addAction(UIAlertAction(title: "Explicit Material", style: .Default, handler: { (alertAction) -> Void in
                why = "Explicit Material"
                self.sendEmail(why)
            }))
            alert.addAction(UIAlertAction(title: "Illicit Goods (Drugs, Weapons)", style: .Default, handler: { (alertAction) -> Void in
                why = "Illicit Goods"
                self.sendEmail(why)
            }))
            alert.addAction(UIAlertAction(title: "Report User", style: .Default, handler: { (alertAction) -> Void in
                why = "user"
                self.sendEmail(why)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    func sendEmail(why: String) {
        var user = "user"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@knotcomplex.com"])
            mail.setSubject("report item")
            var body = "Reporting item " + self.IDNum + " for " + why + " (add any other details here)" + "\n Thanks!"
            if why == user {
                body = "Reporting user " + self.itemSeller + " (add any other details here)" + "\n Thanks!"
                mail.setSubject("report user")
            }
            mail.setMessageBody(body, isHTML: false)
            
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    
    @IBAction func alternatingButton(sender: AnyObject) {
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
        
        if owned {
            //self.performSegueWithIdentifier("paySegue", sender: self)
            let alert = UIAlertController(title: "Are You Sure?", message: "Is this transaction completed?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Mark as Sold", style: .Default, handler: { (alertAction) -> Void in

                self.updateSoldStatus("Sold!")

                self.sold = "true"
                self.timeLabel.text = "Sold!"
                self.timeLabel.textColor = UIColor.greenColor()

                
                self.appDelegate.mixpanel!.track?(
                    "Transaction Completed",
                    properties: ["userID": self.appDelegate.cognitoId!, "item": self.IDNum]
                )
                
                let revenue = Double(self.DetailItem.price)
                self.appDelegate.mixpanel!.people.increment([
                    "Number Sold": 1,
                    "Gross Revenue":  revenue!
                ])
                
                var MixRevenue = String(revenue! * 0.02)
                self.appDelegate.mixpanel!.track?(
                    "Revenue to KCT",
                    properties: ["revenue": MixRevenue]
                )

                self.dataStash(self.IDNum, itemCondition: 5).continueWithBlock({
                    (task: BFTask!) -> BFTask! in
                    
                    if (task.error != nil) {
                        print(task.error!.description)
                    } else {
                        print("DynamoDB save succeeded")
                    }
                    
                    return nil;
                })

                //store revenue data for user
                let syncClient = AWSCognito.defaultCognito()
                let dataset = syncClient.openOrCreateDataset("profileInfo")
                
                dataset.setString(self.DetailItem.price, forKey:"revenue")
                dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                    return nil
                }

                var grossSold = (dataset.stringForKey("gross"))
                var newgross = 1
                if (grossSold == nil || grossSold == "") {
                    newgross = 1
                    //dataset.setString(String(newgross), forKey:"gross")
                }
                else {
                    newgross = Int(grossSold)!
                    newgross = newgross + 1
                }
                dataset.setString(String(newgross), forKey:"gross")
                dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                    return nil
                }

                let alert = UIAlertController(title: "Congrats!", message: "You're listing will disappear from the store feed in a few minutes.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }))
            alert.addAction(UIAlertAction(title: "Relist", style: .Default, handler: { (alertAction) -> Void in
                self.updateTimeStatus()
            }))
            alert.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (alertAction) -> Void in
                self.updateSoldStatus("deleted")
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            if self.sellerSBID.characters.count < 3 {
                let alert = UIAlertController(title: "Oops!", message: "There was an error reaching this user. They probably aren't available for contact.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) -> Void in
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                //let viewController: Messaging = Messaging()
            
                //viewController.viewMode = kMessagingViewMode
                //viewController.messagingTargetUserId = sellerSBID
            
                //self.navigationController?.pushViewController(viewController, animated: true)
                self.performSegueWithIdentifier("contactSegue", sender: self)
                self.appDelegate.mixpanel!.track?("Transaction Initiated", properties: ["senderID": self.appDelegate.cognitoId!, "sellerID" : self.DetailItem.seller, "item": self.DetailItem.ID]
                )
            }
        }
    }

    //when the picture is tapped check if the item has multiple pictures, if it does segue to the screen where the user can view all of them
    @IBAction func ShowOtherPics(sender: AnyObject) {
        if self.numPics > 1 {
            print("about to segue")
            self.performSegueWithIdentifier("ShowPageSegue", sender: self)
        }
    }
    
    //currently not being used, would open Apple Maps when the user taps the mini-map
    func openMapForPlace() {
        /*
        var lat1 : NSString = self.latitude
        var lng1 : NSString = self.longitude
        */
        var latitute:CLLocationDegrees =  self.latitude - 0.01
        var longitute:CLLocationDegrees =  self.longitude + 0.01
        
        let regionDistance:CLLocationDistance = 10000
        var coordinates = CLLocationCoordinate2DMake(latitute, longitute)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        var options = [
            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
        ]
        var placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        var mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.name)"
        mapItem.openInMapsWithLaunchOptions(options)
        
    }
    
    //when the heart button is tapped this method processes the action
    func tapped(sender: DOFavoriteButton) {
        
        //prepare the sync client
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("favorites")
        let value = dataset.stringForKey(self.IDNum)
        
        //track with MixPanel
        self.appDelegate.mixpanel!.track(
            "Favorite Button",
            properties: ["userID": self.cognitoID, "itemID": self.DetailItem.ID]
        )
        
        //if the item is already favorited then unfavorite the item
        if sender.selected {
            // deselect
            //collect view info
            self.dataStash(IDNum, itemCondition: 4).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
            
            sender.deselect()
            dataset.removeObjectForKey(self.IDNum)
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
        }
            
        //if the item has not been favorited then add to favorites and perform the heart popping animation
        else {
            // select with animation
            self.savelabel.text = "Saved!"
            sender.select()
            
            //collect view info
            self.dataStash(IDNum, itemCondition: 1).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
            
            dataset.setString("true", forKey:self.IDNum)
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

        }
    }
    
    //store user data for KRE
    func dataStash(itemId: String, itemCondition: Int) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        var cogID = ""
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                cogID = task.result as! String
            }
            return nil
        }
        
        /***CONVERT FROM NSDate to String ****/
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        let item = KREData()
        item.userID = cogID
        item.itemID = itemId
        item.timestamp = dateString
        item.status = itemCondition
        
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }

    //take a UIImage as a parameter and return a cropped version of the picture with just the center square
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