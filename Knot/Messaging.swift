//
//  messaging.swift
//  Knot
//
//  Created by Nathan Mueller on 1/27/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import SendBirdSDK



class Messaging: UIViewController {
    
    var cognitoID = ""
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
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
        
        var APP_ID = "6D1F1F00-D8E0-4574-A738-4BDB61AF0411"
        var USER_ID = cognitoID
        var USER_NAME = "Nahtna"
        var CHANNEL_URL = "jia_test.Lobby"
        
        let viewController = MessagingTableViewController()
    */
        
        //var sbmessage: SBMessageClass = SBMessageClass()
        
        //sbmessage.startSendBirdMessaging()
    }

}