//
//  MenuController.swift
//  Knot
//
//  Created by Nathan Mueller on 4/7/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import UIKit

class MenuController: UITableViewController {
    
    //@IBOutlet var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    
    // Float rating view params
    @IBOutlet var floatRatingView: FloatRatingView!
    var starRating = 5
    
    var selfRatingArray : [String]!
    var lastEvaluatedKey:[NSObject : AnyObject]!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    let normalColor = UIColor(red: 0, green: 100/255, blue: 118/255, alpha: 1)
    let selectColor = UIColor(red: 0, green: 53/255, blue: 62/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //selfRatingArray = []
        
        self.view.backgroundColor = normalColor
        
        self.floatRatingView.emptyImage = UIImage(named: "empty-star")
        self.floatRatingView.fullImage = UIImage(named: "full-star")
        self.floatRatingView.editable = false
        self.floatRatingView.rating = Float(self.appDelegate.selfRating)
        self.returnUserDataForProf()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func returnUserDataForProf() {
        //get name
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")
        if (dataset.stringForKey("firstName") != nil) {
            var fName = dataset.stringForKey("firstName")
            if (dataset.stringForKey("lastName") != nil) {
                var lName = dataset.stringForKey("lastName")
                self.nameLabel.text = fName + " " + lName
            }
        }
        //self.checkRatings()
        
        self.downloadImage(self.appDelegate.cognitoId!, bucket: "user-prof-photos")
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
                    self.imageFadeIn(self.profPic, image: UIImage(data: data!)!)
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedCell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        selectedCell.contentView.backgroundColor = selectColor
    }
    
    // if tableView is set in attribute inspector with selection to multiple Selection it should work.
    
    // Just set it back in deselect
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        var cellToDeSelect:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        cellToDeSelect.contentView.backgroundColor = normalColor
    }
    

    @IBAction func shareButton(sender: AnyObject) {
        displayShareSheet("Check out Knot Complex on the App Store, buy and sell authentic goods! https://itunes.apple.com/us/app/knot-complex/id1101502916?mt=8")
    }
    
    func displayShareSheet(shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    // MARK: - Table view data source
    
    
    /*
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return NO if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return NO if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
}
