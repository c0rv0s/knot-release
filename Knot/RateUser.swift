//
//  RateUser.swift
//  Knot
//
//  Created by Nathan Mueller on 4/27/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class RateUser: UIViewController {

    @IBOutlet weak var titleText: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    // Float rating view params

    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var descripFieldView: RoundedCornersView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    var otherParty : String!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var credentialsProvider = AWSCognitoCredentialsProvider()
    
    var cognitoID : String!
    
    var selfRating : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.floatRatingView.emptyImage = UIImage(named: "empty-star")
        self.floatRatingView.fullImage = UIImage(named: "full-star")
        self.floatRatingView.editable = true
        self.floatRatingView.rating = 0
        
        self.descripFieldView.layer.borderWidth = 1;
        self.descripFieldView.layer.borderColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1.0).CGColor

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
    }
    
    //store star for future averaging
    func dataStash() -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        var cogID = ""
        credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
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
        
        let item = NewStars()
        item.userID = otherParty
        item.raterID = cogID
        item.timestamp = dateString
        item.stars = Int(self.floatRatingView.rating)
        item.comment = self.commentView.text
        
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }

}