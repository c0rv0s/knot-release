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

class PhotoStreamViewController: UICollectionViewController, LiquidFloatingActionButtonDataSource, LiquidFloatingActionButtonDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate{
    var lock:NSLock?
    var lastEvaluatedKey:[NSObject : AnyObject]!
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet var colView: UICollectionView!
    var collectionItems: Array<ListItem>!
    var filterItems: Array<ListItem>!
    
    //fav items
    var favItemIDs: Array<String>!
    
    //floating button
    var cells: [LiquidFloatingCell] = []
    var floatingActionButton: LiquidFloatingActionButton!

    //end button stuff
    
    //distance filters
    var collectionItemsFav: Array<ListItem>!
    var collectionItemsUnder10: Array<ListItem>!
    var collectionItemsUnder50: Array<ListItem>!
    var collectionItemsUnder100: Array<ListItem>!
    var collectionItemsOver100Miles: Array<ListItem>!
    var collectionImages = [String: UIImage]()
    
    //blocked users
    var blockedUsers: Array<String>!
    
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
    
    //data harvesting
    var performHarvest = true
    
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add search
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.navigationItem.titleView = searchController.searchBar
        
        self.definesPresentationContext = true
        
        /*
        // more testing needed here
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
        } else {
            print("Internet connection FAILED")
            needsToRefresh = false
            var alert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
*/
        
         // Set the PinterestLayout delegate
        if let layout = self.colView.collectionViewLayout as? FeedLayout {
            print("delegated")
            layout.delegate = self
        }
        collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
        
        //reset aray
        self.favItemIDs = []
        self.collectionItems = []
        self.collectionItemsFav = []
        self.collectionItemsUnder10 = []
        self.collectionItemsUnder50 = []
        self.collectionItemsUnder100 = []
        self.collectionItemsOver100Miles = []
        
        
        
        lock = NSLock()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        
        // set up the refresh control
        refreshControl = UIRefreshControl()
        colView.addSubview(refreshControl)
        
        // When activated, invoke our refresh function
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        //self.cognitoID = self.appDelegate.cognitoId!
        
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                self.cognitoID = task.result as! String
                print(self.cognitoID)
            }
            return nil
        }
        
        //fetch blocked users
        
        /*
        //floating action button
        let createButton: (CGRect, LiquidFloatingActionButtonAnimateStyle) -> LiquidFloatingActionButton = { (frame, style) in
            let floatingActionButton = LiquidFloatingActionButton(frame: frame)
            floatingActionButton.animateStyle = style
            floatingActionButton.dataSource = self
            floatingActionButton.delegate = self
            return floatingActionButton
        }
        
        let cellFactory: (String) -> LiquidFloatingCell = { (iconName) in
            return LiquidFloatingCell(icon: UIImage(named: iconName)!)
        }
        cells.append(cellFactory("ic_cloud"))
        cells.append(cellFactory("ic_system"))
        cells.append(cellFactory("ic_place"))
        
        let floatingFrame = CGRect(x: self.view.frame.width - 56 - 16, y: self.view.frame.height - 56 - 16, width: 56, height: 56)
        let bottomRightButton = createButton(floatingFrame, .Up)
        
        let floatingFrame2 = CGRect(x: 16, y: 16, width: 56, height: 56)
        let topLeftButton = createButton(floatingFrame2, .Down)
        
        self.view.addSubview(bottomRightButton)
 */
        
        //fetch KRE data
        self.post(self.cognitoID, url: "https://n30y3ya59k.execute-api.us-east-1.amazonaws.com/prod/KREapi") { (succeeded: Bool, msg: String) -> () in
            //var alert = UIAlertView(title: "Success!", message: msg, delegate: nil, cancelButtonTitle: "Okay.")
            if(succeeded) {
                //alert.title = "Success!"
                //alert.message = msg
            }
            else {
                //alert.title = "Failed : ("
                //alert.message = msg
            }
            // Move to the UI thread 
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert             
                //alert.show()
            })
        }

        if needsToRefresh && appDelegate.loggedIn {
            print("this is happening right here")
            //calculate distance
            
            locationManager = OneShotLocationManager()
            locationManager!.fetchWithCompletion {location, error in
                // fetch location or an error
                if let loc = location {
                    self.locCurrent = loc
                    self.appDelegate.locCurrent = loc
                } else if let err = error {
                    print(err.localizedDescription)
                }
                self.locationManager = nil
            }
            //uncomment these next two lines for running on the simulator
            self.locCurrent = CLLocation(latitude: 37.8051478737647, longitude: -122.426909426833)
            self.appDelegate.locCurrent = CLLocation(latitude: 37.8051478737647, longitude: -122.426909426833)
            self.loadPhotos()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appWasOpened:", name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        
        //menu setup

        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
    }
    
    func appWasOpened(notification: NSNotification!)
    {
        if needsToRefresh == false {
            print("app was opened")
            //reset aray
            self.collectionImages = [String: UIImage]()
            self.favItemIDs = []
            self.collectionItemsFav = []
            self.collectionItems = []
            self.collectionItemsUnder10 = []
            self.collectionItemsUnder50 = []
            self.collectionItemsUnder100 = []
            self.collectionItemsOver100Miles = []
            self.loadPhotos()

        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarHidden=false

        self.colView.reloadData()

    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //aciton button 
    func numberOfCells(liquidFloatingActionButton: LiquidFloatingActionButton) -> Int {
        return cells.count
    }
    
    func cellForIndex(index: Int) -> LiquidFloatingCell {
        return cells[index]
    }
    
    func liquidFloatingActionButton(liquidFloatingActionButton: LiquidFloatingActionButton, didSelectItemAtIndex index: Int) {
        print("did Tapped! \(index)")
        liquidFloatingActionButton.close()
    }
    
    /*
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }*/
    
    func refresh(){
        
        // -- DO SOMETHING AWESOME (... or just wait 3 seconds) --
        // This is where you'll make requests to an API, reload data, or process information
        self.loadPhotos()
        let delayInSeconds = 3.0;
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.refreshControl.endRefreshing()
            //self.colView.reloadData()
        }
        // -- FINISHED SOMETHING AWESOME, WOO! --
    }
    
    func post(param : String, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        self.favItemIDs = []
        self.collectionItemsFav = []
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?

        var jsontext = "{\"userID\": \""  + self.cognitoID + "\"}"
        request.HTTPBody = jsontext.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("w0CrbxlfvCzf6xvOQ35q1wcFXGTO1NY2Ff3mIZjb", forHTTPHeaderField: "x-api-key")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            var strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            var err: NSError?

            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                if let results = json["result"] as? [[String: AnyObject]] {
                    for result in results {
                        if let item = result["itemID"] as? String {
                            self.favItemIDs.append(item)
                        }
                    }
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            var msg = "No message"

        })
        
        task.resume()
    }
    
    @IBAction func filterButton(sender: AnyObject) {
        
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filterItems = self.collectionItems?.filter({  item in
            return item.name.lowercaseString.containsString(searchText.lowercaseString)
        })
        //self.colView.reloadData()
    }
    
    func loadPhotos() {
        
        
        if (self.lock?.tryLock() != nil) {
            self.needsToRefresh = true
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            print("finna fetch those photos")
        
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 50;
        
            dynamoDBObjectMapper.scan(ListItem.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            
                if self.lastEvaluatedKey == nil {
                    self.collectionItems?.removeAll(keepCapacity: true)
                    self.collectionItemsFav?.removeAll(keepCapacity: true)
                    self.collectionItemsUnder10?.removeAll(keepCapacity: true)
                    self.collectionItemsUnder50?.removeAll(keepCapacity: true)
                    self.collectionItemsUnder100?.removeAll(keepCapacity: true)
                    self.collectionItemsOver100Miles?.removeAll(keepCapacity: true)
                }
            
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [ListItem] {
                        if item.sold == "false" {
                            var secondsUntil = self.secondsFrom(self.currentDate, endDate: self.dateFormatter.dateFromString(item.time)!)
                            if (secondsUntil > (0 - 5 * 60)) {
                                self.downloadImage(item)
                                
                                var itemFaved = false
                                
                                if self.favItemIDs.count > 0 {
                                    for idNum in self.favItemIDs {
                                        if item.ID == idNum {
                                            print("new fav added")
                                            self.collectionItemsFav.append(item)
                                            itemFaved = true
                                        }
                                    }
                                }
                               if itemFaved == false {
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
                        }
                    }
                
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.organizeData()
                    //self.colView.reloadData()
                })

                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                    self.loadPhotos()
                }
                return nil
            })

        }
        //self.colView.reloadData()
    }
    
    func organizeData() {
        appDelegate.untapped = []
        print("organize data")
        for item in collectionItemsFav {
            print(item.ID)
            appDelegate.untapped!.append(item.ID)
            self.collectionItems!.append(item)
        }
        print("done with favs")
        for item in collectionItemsUnder10 {
            print(item.ID)
            appDelegate.untapped!.append(item.ID)
            self.collectionItems!.append(item)
        }
        for item in collectionItemsUnder50 {
            print(item.ID)
            appDelegate.untapped!.append(item.ID)
            self.collectionItems!.append(item)
        }
        for item in collectionItemsUnder100 {
            print(item.ID)
           appDelegate.untapped!.append(item.ID)
            self.collectionItems!.append(item)
        }
        for item in collectionItemsOver100Miles {
            print(item.ID)
            appDelegate.untapped!.append(item.ID)
            self.collectionItems!.append(item)
        }
        self.colView.reloadData()
        self.needsToRefresh = false
        self.performHarvest = false

        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    func downloadImage(item: ListItem){
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?

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
                }
                else{
                    
                    self.collectionImages[S3DownloadKeyName] = UIImage(data: data!)
                    
                    if self.needsToRefresh == false {
                        if let count = (self.collectionItems.indexOf(item)) {
                            var indexPath = NSIndexPath(forItem: count, inSection: 0)
                            if self.colView.cellForItemAtIndexPath(indexPath) != nil {
                                self.colView.reloadItemsAtIndexPaths([indexPath])
                                
                            }
                        }
                            
                        else {
                            self.colView.reloadData()
                        }
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
    
    func indexPathIsValid(indexPath: NSIndexPath) -> Bool
    {
       let row = indexPath.row

        let rowCount = self.collectionView(
            self.colView, numberOfItemsInSection: indexPath.section) - 1
        
        return row <= rowCount
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return self.filterItems!.count
        }
        else {
            return self.collectionItems!.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selectedRow = indexPath.row
        self.performSegueWithIdentifier("FeedDetailSeg", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "FeedDetailSeg") {
            let viewController:ItemDetail = segue!.destinationViewController as! ItemDetail
            viewController.hidesBottomBarWhenPushed = true
            
            //viewController.pic = collectionImages[collectionItems![self.selectedRow].ID]!
            
            viewController.DetailItem = collectionItems![self.selectedRow]
/*
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
            //viewController.category = collectionItems![self.selectedRow].category
            viewController.numPics = collectionItems![self.selectedRow].numberOfPics
            viewController.sellerSBID = collectionItems![self.selectedRow].sellerSBID
 */
            
            if self.cognitoID == collectionItems![self.selectedRow].seller {
                viewController.owned = true
            }
            else {
                viewController.owned = false
            }
            
            //remove item from untapped
            appDelegate.untapped.removeAtIndex(self.selectedRow)
            
            //collect view info
            self.dataStash(collectionItems![self.selectedRow].ID, itemCondition: 2).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })

        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AnnotatedPhotoCell", forIndexPath: indexPath) as! AnnotatedPhotoCell
        
        if searchController.active && searchController.searchBar.text != "" {
            cell.cellItem = self.filterItems![indexPath.row]
        } else {
            cell.cellItem = self.collectionItems![indexPath.row]
        }
        
        
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

