//
//  launchScreen.swift
//  Knot
//
//  Created by Nathan Mueller on 2/11/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit

class launchScreen: UIViewController {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var cognitoID : String!
    
    var selfRating : [String]!
    var lastEvaluatedKey:[NSObject : AnyObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden=true
        // Retrieve your Amazon Cognito ID
        if FBSDKAccessToken.currentAccessToken() != nil {
            print("user logged in")
            let token = FBSDKAccessToken.currentAccessToken().tokenString
            appDelegate.credentialsProvider.logins = [AWSCognitoLoginProviderKey.Facebook.rawValue: token]
            appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
                
                if (task.error != nil) {
                    print("CognitoID Error: " + task.error!.localizedDescription)
                    
                }
                else {
                    self.appDelegate.cognitoId = task.result as! String
                    self.cognitoID = task.result as! String
                    self.appDelegate.loggedIn = true
                    
                    //check in with mixpanel
                    self.appDelegate.mixpanel?.identify(self.appDelegate.cognitoId!)
                    print("login was a success, consider putting stuff here")
                    
                    //update your star rating
                    self.returnStars()
                    self.checkRatings()
                    
                }
                return nil
            }
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.appDelegate.loggedIn {
            self.performSegueWithIdentifier("OpenRevealView", sender: self)
        }
        else {
            print("second chance")
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
            self.presentViewController(vc, animated: false, completion: nil)
        }
        
    }
    
    func returnStars() {
        //get name
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")

        if (dataset.stringForKey("rating") != nil) {
            self.selfRating = (dataset.stringForKey("rating")).characters.split{$0 == ","}.map(String.init)
        }

    }

    
    func checkRatings() {
        
        
        //if (self.lock?.tryLock() != nil) {
          //  self.needsToRefresh = true
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            print("finna fetch those ratings")
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBScanExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 50;
            
            dynamoDBObjectMapper.scan(NewStars.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                var starTotal = 5
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [NewStars] {
                        starTotal = item.stars
                        if item.userID == self.cognitoID {
                            for star in self.selfRating {
                                starTotal += Int(star)!
                            }
                        }
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                }
                self.appDelegate.selfRating = starTotal/(self.selfRating.count)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                   // self.loadPhotos()
                }
                return nil
            })
            
        //}
        //self.colView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "startApp") {
            appDelegate.startApp = true
            //let viewController:HomeTabBarController = segue!.destinationViewController as! HomeTabBarController
            //viewController.startApp = true
        }
    }
 
}
