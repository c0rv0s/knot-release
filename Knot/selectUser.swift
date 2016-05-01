//
//  selectUser.swift
//  Knot
//
//  Created by Nathan Mueller on 4/30/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit
import SendBirdSDK
import MobileCoreServices


class SelectUser: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableRows : Array<String>?
    @IBOutlet weak var question: UILabel!
    var credentialsProvider = AWSCognitoCredentialsProvider()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    private var messagingChannelListQuery: SendBirdMessagingChannelListQuery?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom cell
        let nib = UINib(nibName: "selectUserCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.startSendBird("derp")
        
        self.messagingChannelListQuery = SendBird.queryMessagingChannelList()
        
        getUsers()
        tableRows = []
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    // 2
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableRows!.count
    }
    
    // 3
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 	{
        let cell:selectUserCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! selectUserCell
        cell.nameLabel.text = tableRows![indexPath.row]
        print(cell.nameLabel.text)
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "userSelected") {
            let viewController:RateUser = segue!.destinationViewController as! RateUser
            let indexPath = self.tableView.indexPathForSelectedRow
            viewController.otherParty = tableRows![indexPath!.row]
        }
    }
    
    
    // 4
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("userSelected", sender: tableView)
    }
    
    // 5
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    private func startSendBird(userName: String) {
        let APP_ID: String = "6D1F1F00-D8E0-4574-A738-4BDB61AF0411"
        let USER_ID: String = self.appDelegate.SBID!
        let USER_NAME: String = userName
        
        print("SendBirdUserID in auth = " + USER_ID)

        SendBird.initAppId(APP_ID, withDeviceId: USER_ID)
        
    }
    
    //get list of users
    func getUsers() {
        self.messagingChannelListQuery = SendBird.queryMessagingChannelList()
        self.messagingChannelListQuery?.setLimit(15)
        if self.messagingChannelListQuery?.hasNext() == true {
            self.messagingChannelListQuery?.nextWithResultBlock({ (queryResult) -> Void in
                for user in queryResult {
                    print(user)
                    self.tableRows?.append(user as! String)
                }
                
                }, endBlock: { (code) -> Void in
                    
            })
        }
        self.tableView.reloadData()
    }
    
}


