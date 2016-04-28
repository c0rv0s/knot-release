//
//  notifications.swift
//  Knot
//
//  Created by Nathan Mueller on 4/28/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class Notifications: UITableViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //menu setup
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
}