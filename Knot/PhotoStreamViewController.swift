//
//  CollectionViewController.swift
//  Knot
//
//  Created by Nathan Mueller on 1/20/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class PhotoStreamViewController: UICollectionViewController {
    var lock:NSLock?
    var lastEvaluatedKey:[NSObject : AnyObject]!
    
    @IBOutlet var colView: UICollectionView!
    var collectionItems: Array<ListItem>!
    
    //distance filters
    var collectionItemsUnder10: Array<ListItem>!
    var collectionItemsUnder50: Array<ListItem>!
    var collectionItemsUnder100: Array<ListItem>!
    var collectionItemsOver100Miles: Array<ListItem>!
    var collectionImages = [String: UIImage]()
    
    let currentDate = NSDate()
    let dateFormatter = NSDateFormatter()
    
    var cognitoID = ""
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var selectedRow: Int!
    
    var refreshControl = UIRefreshControl()
    var needsToRefresh = true
    
    //location
    var locationManager: OneShotLocationManager!
    var locCurrent: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // Set the PinterestLayout delegate
        if let layout = self.colView.collectionViewLayout as? FeedLayout {
            print("delegated")
            layout.delegate = self
        }
        collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        /*
        //calculate distance
        locationManager = OneShotLocationManager()
        locationManager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.locCurrent = loc
            } else if let err = error {
                print(err.localizedDescription)
            }
            self.locationManager = nil
        }*/
        
        
        lock = NSLock()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"

        //reset aray
        self.collectionItems = []
        self.collectionItemsUnder10 = []
        self.collectionItemsUnder50 = []
        self.collectionItemsUnder100 = []
        self.collectionItemsOver100Miles = []
        
        // set up the refresh control
        refreshControl = UIRefreshControl()
        colView.addSubview(refreshControl)
        
        // When activated, invoke our refresh function
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        
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
        
        print(needsToRefresh)
        /*
        //testcode
        if needsToRefresh {
            self.locCurrent = appDelegate.locCurrent
            self.loadPhotos()
        }
        */
        if needsToRefresh {
            if self.appDelegate.locCurrent != nil {
                self.locCurrent = appDelegate.locCurrent
                self.loadPhotos()
            }
            else {
                var delayInSeconds = 1.5;
                var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
                dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                    if self.appDelegate.locCurrent != nil {
                        self.locCurrent = self.appDelegate.locCurrent
                        self.loadPhotos()
                    }
                }
            }
        }
        self.colView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden=false
        
        if needsToRefresh {
            self.loadPhotos()
        }
        self.colView.reloadData()

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.colView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func refresh(){
        
        // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
        // This is where you'll make requests to an API, reload data, or process information
        self.loadPhotos()
        var delayInSeconds = 3.0;
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl.endRefreshing()
            self.colView.reloadData()
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    func loadPhotos() {
        if (self.lock?.tryLock() != nil) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            print("finna fetch those photos")
        
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 500;
            print("fuck")
        
            dynamoDBObjectMapper.scan(ListItem.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
                if self.lastEvaluatedKey == nil {
                    self.collectionItems?.removeAll(keepCapacity: true)
                }
            
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [ListItem] {
                        if item.sold == "false" {
                            var secondsUntil = self.secondsFrom(self.currentDate, endDate: self.dateFormatter.dateFromString(item.time)!)
                            if (secondsUntil > 0) {
                                self.downloadImage(item)
                            
                                let coordinatesArr = item.location.characters.split{$0 == " "}.map(String.init)
                                let latitude = Double(coordinatesArr[0])!
                                let longitude = Double(coordinatesArr[1])!
                            
                                let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
                                let distanceBetween = itemLocation.distanceFromLocation(self.locCurrent) * 0.000621371
                                print(String(format: "%.1f", distanceBetween) + " miles away")
                            
                                if distanceBetween < 10 {
                                    self.collectionItemsUnder10.append(item)
                                }
                                else if distanceBetween >= 10 && distanceBetween < 50 {
                                    self.collectionItemsUnder50.append(item)
                                }
                                else if distanceBetween >= 50 && distanceBetween < 100 {
                                    self.collectionItemsUnder100.append(item)
                                }
                                else {
                                    self.collectionItemsOver100Miles.append(item)
                                }
                            }
                        }
                        //store data
                        //self.dataStash(item.ID, itemCondition: 3)
                    }
                
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.organizeData()
                    self.colView.reloadData()
                })

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                    self.loadPhotos()
                }
                return nil
            })

        }
    }
    
    func organizeData() {
        print("organize data")
        for item in collectionItemsUnder10 {
            self.collectionItems!.append(item)
        }
        for item in collectionItemsUnder50 {
            self.collectionItems!.append(item)
        }
        for item in collectionItemsUnder100 {
            self.collectionItems!.append(item)
        }
        for item in collectionItemsOver100Miles {
            self.collectionItems!.append(item)
        }
        self.needsToRefresh = false
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
                    
                    self.collectionImages[S3DownloadKeyName] = UIImage(data: data!)
                    
                    /*
                    let count = (self.collectionItems.indexOf(item)! - 1)
                    print("count = \(count)")
                    let indexPath = NSIndexPath(forItem: count, inSection: 0)
                    //self.colView.reloadItemsAtIndexPaths([indexPath])
                    //self.colView.reloadData()
*/
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
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionItems!.count
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.performSegueWithIdentifier("FeedDetailSeg", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "FeedDetailSeg") {
            let viewController:ItemDetail = segue!.destinationViewController as! ItemDetail
            viewController.hidesBottomBarWhenPushed = true
            
            viewController.pic = collectionImages[collectionItems![self.selectedRow].ID]!

            viewController.name = collectionItems![self.selectedRow].name
            viewController.price = collectionItems![self.selectedRow].price
            viewController.time = collectionItems![self.selectedRow].time
            viewController.IDNum = collectionItems![self.selectedRow].ID
            viewController.itemSeller = collectionItems![self.selectedRow].seller
            viewController.location = collectionItems![self.selectedRow].location
            viewController.sold = collectionItems![self.selectedRow].sold
            viewController.fbID = collectionItems![self.selectedRow].sellerFBID
            viewController.descript = collectionItems![self.selectedRow].descriptionKnot
            viewController.condition = collectionItems![self.selectedRow].condition
            viewController.category = collectionItems![self.selectedRow].category
            viewController.numPics = collectionItems![self.selectedRow].numberOfPics
            viewController.sellerSBID = collectionItems![self.selectedRow].sellerSBID
            
            if self.cognitoID == collectionItems![self.selectedRow].seller {
                viewController.owned = true
            }
            else {
                viewController.owned = false
            }

        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnnotatedPhotoCell", forIndexPath: indexPath) as! AnnotatedPhotoCell
        
        
        cell.cellItem = collectionItems![indexPath.row]
        
        cell.cellPic = collectionImages[collectionItems![indexPath.row].ID]

        let overDate = self.dateFormatter.dateFromString(cell.cellItem.time)!
        let secondsUntil = secondsFrom(currentDate, endDate: overDate)
        if(secondsUntil > 0)
        {
            cell.countdownLabel.text = printSecondsToDaysHoursMinutesSeconds(secondsUntil)
            if secondsUntil < 43200 {
                cell.countdownLabel.textColor = UIColor.redColor()
            }
            else {
                cell.countdownLabel.textColor = UIColor.blackColor()
            }
        }
        else {
            cell.countdownLabel.textColor = UIColor.redColor()
            cell.countdownLabel.text = "Ended"
        }
        cell.titleLabel.text = cell.cellItem.name
        cell.imageView.image = cell.cellPic
        cell.alpha = 0
        
        UICollectionViewCell.animateWithDuration(0.25, animations: { cell.alpha = 1 })
        //print("cell made")
        
        return cell
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
    
    //store user data
    func dataStash(itemId: String, itemCondition: Int) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        /***CONVERT FROM NSDate to String ****/
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        let item = sessionData()
        item.userID = "\(self.cognitoID)"
        item.itemID = itemId
        item.timeStamp = dateString
        item.condition = itemCondition
        
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }
    
    /*
    func imageFadeIn(imageView: UIImageView) {
        
        let secondImageView = UIImageView(image: UIImage(named: "bg02.png"))
        secondImageView.frame = view.frame
        secondImageView.alpha = 0.0
        
        view.insertSubview(secondImageView, aboveSubview: imageView)
        
        UIView.animateWithDuration(2.0, delay: 2.0, options: .CurveEaseOut, animations: {
            secondImageView.alpha = 1.0
            }, completion: {_ in
                imageView.image = secondImageView.image
                secondImageView.removeFromSuperview()
        })
        
    }
*/

}

extension PhotoStreamViewController : FeedLayoutDelegate {
    // 1. Returns the photo height
    func collectionView(collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:NSIndexPath , withWidth width:CGFloat) -> CGFloat {
        var photo: UIImage
        if collectionImages[collectionItems![indexPath.row].ID] != nil {
            photo = collectionImages[collectionItems![indexPath.row].ID]!
        }
        else {
            photo = UIImage(named: "example")!
        }
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRectWithAspectRatioInsideRect(photo.size, boundingRect)
        return rect.size.height
    }
    
    // 2. Returns the annotation size based on the text
    func collectionView(collectionView: UICollectionView, heightForAnnotationAtIndexPath indexPath: NSIndexPath, withWidth width: CGFloat) -> CGFloat {
        return 60
    }
}

