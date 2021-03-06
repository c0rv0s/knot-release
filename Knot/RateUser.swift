//
//  RateUser.swift
//  Knot
//
//  Created by Nathan Mueller on 4/27/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class RateUser: UIViewController, UITextViewDelegate {

    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    // Float rating view params

    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var descripFieldView: RoundedCornersView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    var otherParty : String!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var credentialsProvider = AWSCognitoCredentialsProvider()
    
    var selfRating : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.floatRatingView.emptyImage = UIImage(named: "empty-star")
        self.floatRatingView.fullImage = UIImage(named: "full-star")
        self.floatRatingView.editable = true
        self.floatRatingView.rating = 0
        
        self.commentView.delegate = self
        self.descripFieldView.layer.borderWidth = 1;
        self.descripFieldView.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor
        
        //get potential users
    
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func saveButton(sender: AnyObject) {
            self.dataStash().continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    //store star for future averaging
    func dataStash() -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        /***CONVERT FROM NSDate to String ****/
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        otherParty = "placeholder"
        
        let item = NewStars()
        item.userID = otherParty
        item.raterID = self.appDelegate.cognitoId!
        item.timestamp = dateString
        item.stars = Int(self.floatRatingView.rating)
        item.comment = self.commentView.text
        
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }

}