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
    
    @IBOutlet weak var savelabel: UILabel!
    @IBOutlet weak var favButton: DOFavoriteButton!
    /*
    @IBOutlet weak var imageScroll: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
*/
    @IBOutlet weak var openMaps: UIButton!
    
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
    //@IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    var picView: UIImageView!
    var pic : UIImage!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width:375, height: 1140)
        self.downloadImage(IDNum)
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        self.locCurrent = appDelegate.locCurrent
        self.openMaps.hidden = true
        
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
        /*
        //paging
        // 1
        self.pageImages = []
        self.pageImages.append(pic)
        //self.pageImages.append(UIImage(named: "Knot380")!)
        if numPics > 1 {
            print("two pics yea")
            self.downloadImage(IDNum, bucketName: "knotcompleximage2")
            if numPics > 2 {
                print("three pics yea")
                self.downloadImage(IDNum, bucketName: "knotcompleximage3")
            }
        }
        
        let pageCount = numPics
        
        // 2
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        // 3
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // 4
        let pagesScrollViewSize = imageScroll.frame.size
        imageScroll.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count),
            height: pagesScrollViewSize.height)

        // 5
        loadVisiblePages()
        
        //paging done
        */
        
        
        //set button state
        if self.owned {
            self.alternatingButton.setTitle("Mark As Sold", forState: .Normal)
        }
        else {
            self.alternatingButton.setTitle("Contact", forState: .Normal)
        }
        
        //set labels
        descripText.text = descript
        descripText.editable = false
        
        //something important here
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                self.cognitoID = task.result as! String
            }
            return nil
        }
        
        //do some more setup stuff
        self.returnUserData()
        self.updateLocation()
        
        picView = UIImageView(frame:CGRectMake(0, 0, 380, 506))
        
        nameLabel.text = name
        priceLabel.text = "$" + price
        categoryLabel.text = self.category
        conditionLabel.text = self.condition
        picView.image = pic
        
        
        //set up countdown and timer stuff

        //let overDate =
        //let currentDate =
        
        self.scrollView.addSubview(picView)
        self.scrollView.sendSubviewToBack(picView)
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

                if let url = NSURL(string: result.valueForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                    if let data = NSData(contentsOfURL: url){
                        var profilePicture = UIImage(data: data)
                        
                        self.profPic.image = profilePicture
                    }
                }
                
            }
        })
    }
    
    func downloadImage(key: String){
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        //downloading image
        
        
        let S3BucketName: String = "knotcompleximages"
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
                    //    self.statusLabel.text = "Success"
                    self.picView.image = UIImage(data: data!)
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
            self.alternatingButton.hidden = true
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
        self.latitude = Double(coordinatesArr[0])!
        self.longitude = Double(coordinatesArr[1])!
        
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        let regionRadius: CLLocationDistance = 500
        func centerMapOnLocation(location: CLLocation) {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                regionRadius * 3.5, regionRadius * 3.5)
            map.setRegion(coordinateRegion, animated: true)
        }
        let location = self.scrambleLoc(latitude, longitude: longitude)

        centerMapOnLocation(location)
        
        //find the distance
        let distanceBetween = initialLocation.distanceFromLocation(self.locCurrent) * 0.000621371
        self.distanceLabel.text = "About " + String(format: "%.0f", distanceBetween + 1) + " miles away"
        
        //now print out the address
        var address = ""
        var streetHolder = ""
        var cityHolder = ""
        
        let geoCoder = CLGeocoder()
        self.addRadiusCircle(location)
        /*
        geoCoder.reverseGeocodeLocation(location)
            {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                // Address dictionary
                print(placeMark.addressDictionary)
                
                // Street address
                if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
                {
                    print(street)
                    streetHolder = street as String
                }
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                    print(city)
                    
                    cityHolder = (city as String)
                }
                address = streetHolder + ", " + cityHolder
                self.addressLabel.text = address
        }*/
        
    }
    
    func scrambleLoc(var latitude: Double, var longitude: Double) -> CLLocation {
        var newLat = latitude - 0.005
        var newLon = longitude + 0.005
        
        return CLLocation(latitude: newLat, longitude: newLon)
    }
    
    func addRadiusCircle(location: CLLocation){
        self.map.delegate = self
        var circle = MKCircle(centerCoordinate: location.coordinate, radius: 50 as CLLocationDistance)
        self.map.addOverlay(circle)
    }
    
    
    
    func updateSoldStatus(type: String) {
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
        
        self.sold = "Sold!"
        AWSDynamoDB.defaultDynamoDB().updateItem(updateInput).waitUntilFinished()
    }
    /*
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "paySegue") {
            let viewController:QRView = segue!.destinationViewController as! QRView
            viewController.price = price
            viewController.ID = IDNum
            viewController.time = time
        }
        
    }
    */
    @IBAction func reportuser(sender: AnyObject) {
        var why = "Cancel"
        let alert = UIAlertController(title: "Report Item", message: "Please select an option: ", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Violence", style: .Default, handler: { (alertAction) -> Void in
            why = "Violence"
            self.sendEmail(why)
        }))
        alert.addAction(UIAlertAction(title: "Nudity", style: .Default, handler: { (alertAction) -> Void in
            why = "Nudity"
            self.sendEmail(why)
        }))
        alert.addAction(UIAlertAction(title: "Illicit Goods (Drugs, Weapons)", style: .Default, handler: { (alertAction) -> Void in
            why = "Nudity"
            self.sendEmail(why)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func sendEmail(why: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["hashwage@gmail.com"])
            var body = "Reporting item " + IDNum + " for " + why + " (add any other details here)" + "\n Thanks!"
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
        if owned {
            //self.performSegueWithIdentifier("paySegue", sender: self)
            let alert = UIAlertController(title: "Are You Sure?", message: "Is this transaction completed?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (alertAction) -> Void in
                self.updateSoldStatus("Sold!")
                self.timeLabel.text = "Sold!"
                self.timeLabel.textColor = UIColor.greenColor()
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
                let viewController: Messaging = Messaging()
            
                viewController.viewMode = kMessagingViewMode
                viewController.messagingTargetUserId = sellerSBID
            
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }
    
    @IBAction func openMaps(sender: AnyObject) {
        self.openMapForPlace()
    }
    
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
    
    func tapped(sender: DOFavoriteButton) {
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("favorites")
        let value = dataset.stringForKey(self.IDNum)
        
        if sender.selected {
            // deselect
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
        } else {
            // select with animation
            self.savelabel.text = "Saved!"
            sender.select()
            
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
    
    /*
    //download iamge
    func downloadImage(key: String, bucketName: String){
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        //downloading image
        
        
        let S3BucketName: String = bucketName
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
                    //    self.statusLabel.text = "Success"
                    self.pageImages.append(UIImage(data: data!)!)
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility?.downloadToURL(nil, bucket: S3BucketName, key: S3DownloadKeyName, expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
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
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Load an individual page, first checking if you've already loaded it
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            frame = CGRectInset(frame, 10.0, 0.0)
            
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
*/
}