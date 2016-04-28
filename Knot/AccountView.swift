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

class AccountView: UIViewController, MFMailComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource{
//currently selling stuff
    @IBOutlet weak var tableView: UITableView!
    var tableRows: Array<ListItem>?
    var filterRows: Array<ListItem>?
    var downloadFileURLs = Array<NSURL?>()
    var tableImages = [String: UIImage]()
    var cropImages = [String: UIImage]()

    var  doneLoading = false
    
    var needsToRefresh = false
    
    let currentDate = NSDate()
    let dateFormatter = NSDateFormatter()
    
    var lock:NSLock?
    var lastEvaluatedKey:[NSObject : AnyObject]!
    //end
    
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
            //self.profCompleteLabel.text = "Profile Incomplete"
        }
        
        //store revenue data for user
        if let value3 = dataset.stringForKey("revenue") {
            self.revenueLabel.text = "$" + value3
        }
        
        if let value4 = dataset.stringForKey("gross") {
            self.numSoldLabel.text = value4
        }
        
        // Register custom cell
        let nib = UINib(nibName: "storeTableCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        self.automaticallyAdjustsScrollViewInsets = false
        
        //download data
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        tableRows = []
        lock = NSLock()
        self.refreshList(true)

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
        self.floatRatingView.rating = Float(self.appDelegate.selfRating)
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
    
    func refreshList(startFromBeginning: Bool)  {
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20;
            dynamoDBObjectMapper.scan(ListItem.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepCapacity: true)
                }
                
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [ListItem] {
                        print(item.seller)
                        if item.seller == self.appDelegate.cognitoId {
                            print(item.sold)
                            if item.sold == "false" {
                                var secondsUntil = self.secondsFrom(self.currentDate, endDate: self.dateFormatter.dateFromString(item.time)!)
                                if (secondsUntil > (0 - 60 * 60 * 24 * 12)) {
                                    self.tableRows?.append(item)
                                    self.downloadImage(item)
                                }
                            }
                        }
                        
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.tableView.reloadData()
                
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
                return nil
            })
        
    }
    
    func downloadImage(item: ListItem){
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        //downloading image
        
        
        let S3BucketName: String = "knotcomplexthumbnails"
        let S3DownloadKeyName: String = item.ID
        
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
                    self.tableImages[S3DownloadKeyName] = UIImage(data: data!)
                    self.cropImages[S3DownloadKeyName] = self.cropToSquare(image: UIImage(data: data!)!)
                    
                    if self.needsToRefresh == false {
                        if let count = (self.tableRows!.indexOf(item)) {
                            var indexPath = NSIndexPath(forItem: count, inSection: 0)
                            if self.tableView.cellForRowAtIndexPath(indexPath) != nil {
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                            }
                        }
                            
                        else {
                            self.tableView.reloadData()
                        }
                    }
                    //self.tableView.reloadData()
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
    
    override func viewDidLayoutSubviews() {
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
    }
    
    // 2
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableRows!.count
    }
    
    
    // 3
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 	{
        
        let cell:PersonalTableCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! PersonalTableCell
        
        cell.cellItem = self.tableRows![indexPath.row]
        
        
        cell.nameLabel.text = cell.cellItem.name
        //cell.priceLabel.text = "$" + cell.cellItem.price
        
        cell.pic.image = cropImages[cell.cellItem.ID]
        
        if cell.cellItem.sold == "true" {
            cell.timeLabel.text = "Sold!"
            cell.timeLabel.textColor = UIColor.greenColor()
        }
        else {
            let overDate = dateFormatter.dateFromString(cell.cellItem.time)!
            let secondsUntil = secondsFrom(currentDate, endDate: overDate)
            if(secondsUntil > 0)
            {
                cell.timeLabel.text = printSecondsToDaysHoursMinutesSeconds(secondsUntil)
                if secondsUntil < 43200 {
                    cell.timeLabel.textColor = UIColor.redColor()
                }
                else {
                    cell.timeLabel.textColor = UIColor.blackColor()
                }
            }
            else {
                cell.timeLabel.textColor = UIColor.redColor()
                cell.timeLabel.text = "Ended"
            }
        }
        
        cell.alpha = 0
        
        UITableViewCell.animateWithDuration(0.25, animations: { cell.alpha = 1 })
        return cell
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        
        if (segue!.identifier == "CurrentlySellingSeuge") {
            let viewController:ItemDetail = segue!.destinationViewController as! ItemDetail
            let indexPath = self.tableView.indexPathForSelectedRow
            viewController.DetailItem = tableRows![indexPath!.row]
            
        }
        
    }
    
    
    // 4
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("CurrentlySellingSeuge", sender: tableView)
        
    }
    
    // 5
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func refresh(sender:AnyObject) {
        let nib = UINib(nibName: "storeTableCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    //timer setup stuff
    func secondsToDaysHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 86400, (seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func printSecondsToDaysHoursMinutesSeconds (seconds:Int) -> String {
        let (d, h, m, s) = secondsToDaysHoursMinutesSeconds (seconds)
        //more than 1 day remaining
        if d > 0 {
            if m < 10 {
                return "\(d) Days, \(h):0\(m) left"
            }
            return "\(d) Days, \(h):\(m) left"
        }
            //less than a day less
        else {
            if m < 10 {
                if s < 10 {
                    return "\(h):0\(m):0\(s) left"
                }
                return "\(h):0\(m):\(s) left"
            }
            if s < 10 {
                return "\(h):\(m):0\(s) left"
            }
            return "\(h):\(m):\(s) left"
            
        }
    }
    
    func secondsFrom(startDate:NSDate, endDate:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: startDate, toDate: endDate, options: []).second
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