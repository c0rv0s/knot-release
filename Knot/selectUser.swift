//
//  selectUser.swift
//  Knot
//
//  Created by Nathan Mueller on 4/30/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class SelectUser: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tableRows : Array<String>?
    @IBOutlet weak var question: UILabel!
    var credentialsProvider = AWSCognitoCredentialsProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom cell
        let nib = UINib(nibName: "selectUserCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "cell")
        self.automaticallyAdjustsScrollViewInsets = false
        
        getUsers()
        tableRows = ["der", "berp", "lerp"]
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
    
    //get lsit of users
    func getUsers() {
        
    }
    
}