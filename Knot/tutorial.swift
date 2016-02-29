//
//  tutorial.swift
//  Knot
//
//  Created by Nathan Mueller on 2/12/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit

class tutorial: UIViewController {
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contButton: UIButton!
    @IBOutlet weak var topLabel: UITextView!
    @IBOutlet weak var secondLabel: UITextView!
    @IBOutlet weak var thirdLabel: UITextView!
    
    var count = 0
    
    //help text
    var homeTop = "This is the Home View, this is where you see what's for sale around you"
    var homeSec = "Tap on items that look interesting for a more in-depth view"
    
    var detailTwoTop = "Tapping an item shows you details on the listing. Tap the contact button to start messaging the owner"

    var storeTop = "See your own listings here. When you've sold an item be sure to mark it sold so it'll be removed from the feed!"
    
    
    var shapeLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topLabel.editable = false
        self.secondLabel.editable = false
        self.thirdLabel.editable = false
        
        self.hide()
        
        // fade in
        self.topLabel.text = homeTop
        self.topLabel.hidden = false

        
    }
    
    @IBAction func contButton(sender: AnyObject) {
        switch(count) {
        case 0:
            self.secondLabel.text = homeSec
            self.secondLabel.hidden = false
            break
            
        case 1:
            self.hide()
            imageView.image = UIImage(named: "detail 2")
            self.topLabel.text = detailTwoTop
            self.topLabel.hidden = false
            break
            
        case 2:
            self.hide()
            imageView.image = UIImage(named: "store")
            self.topLabel.text = storeTop
            self.topLabel.hidden = false
            
            break
            
        default:
            self.performSegueWithIdentifier("tutorialDone", sender: self)
            break
        }
        self.count++
    }
    
    func hide() {
        self.topLabel.hidden = true
        self.secondLabel.hidden = true
        self.thirdLabel.hidden = true
    }
}
