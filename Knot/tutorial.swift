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
    var homeTop = "This is the Home View. Think of its as your newsfeed for checking out what’s for sale around you"
    var homeSec = "Tap on items that look interesting for a more in-depth view"
    
    var detailOneTop = "This view provides more details on a listing"
    var detailOneSec = "Tap the flag to report items that violate guidelines. The item disapears when the timer runs out"
    
    var detailTwoTop = "Farther down shows more detail on the listing and its seller. Tap the map for directions"
    var detailTwoSec = "If you own the listing the button along the bottom of the screen will let you close the item once you've sold it"
    var detailTwoThird = "If you don't own the listing that button will let you contact the seller"
    
    var messageSec = "When you contact a seller or a buyer contacts you about a listing your conversation will show up here"
    
    var newTop = "When you tap the plus button in the center of the bottom tab bar this screen opens"
    var newSec = "Use this view to take a photo and add details about your listing"
    var newThird = "Make sure to enter all fields! Your listing won’t upload otherwise"
    
    var storeTop = "This screen shows the listings you have that are currently available, and also your past listings that either ended or were sold"
    
    var accountSec = "This screen shows your account info and gives you the option to change any of it and also contact support"
    
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
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 34,y: 634), radius: CGFloat(24), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        

        shapeLayer.path = circlePath.CGPath
        
        //change the fill color
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.redColor().CGColor
        //you can change the line width
        shapeLayer.lineWidth = 3.0
        
        view.layer.addSublayer(shapeLayer)
        
    }
    
    @IBAction func contButton(sender: AnyObject) {
        switch(count) {
        case 0:
            self.secondLabel.text = homeSec
            self.secondLabel.hidden = false
            break
            
        case 1:
            shapeLayer.removeFromSuperlayer()
            self.hide()
            self.topLabel.text = detailOneTop
            self.topLabel.hidden = false
            imageView.image = UIImage(named: "detail 1")
            break
            
        case 2:
            self.secondLabel.text = detailOneSec
            self.secondLabel.hidden = false
            break
            
        case 3:
            self.hide()
            imageView.image = UIImage(named: "detail 2")
            self.topLabel.text = detailTwoTop
            self.topLabel.hidden = false
            break
            
        case 4:
            self.secondLabel.text = detailTwoSec
            self.secondLabel.hidden = false
            break
            
        case 5:
            self.thirdLabel.text = detailTwoThird
            self.thirdLabel.hidden = false
            break
            
        case 6:
            self.hide()
            imageView.image = UIImage(named: "messages")
            self.secondLabel.text = messageSec
            self.secondLabel.hidden = false
            
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 115,y: 634), radius: CGFloat(24), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
            
            
            shapeLayer.path = circlePath.CGPath
            
            //change the fill color
            shapeLayer.fillColor = UIColor.clearColor().CGColor
            //you can change the stroke color
            shapeLayer.strokeColor = UIColor.redColor().CGColor
            //you can change the line width
            shapeLayer.lineWidth = 3.0
            
            view.layer.addSublayer(shapeLayer)
            break
            
        case 7:
            shapeLayer.removeFromSuperlayer()
            self.hide()
            imageView.image = UIImage(named: "new")
            self.topLabel.text = newTop
            self.topLabel.hidden = false
            break
            
        case 8:
            self.secondLabel.text = newSec
            self.secondLabel.hidden = false
            break
            
        case 9:
            self.thirdLabel.text = newThird
            self.thirdLabel.hidden = false
            break
            
        case 10:
            self.hide()
            imageView.image = UIImage(named: "store")
            self.topLabel.text = storeTop
            self.topLabel.hidden = false
            
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 263,y: 634), radius: CGFloat(24), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
            
            
            shapeLayer.path = circlePath.CGPath
            
            //change the fill color
            shapeLayer.fillColor = UIColor.clearColor().CGColor
            //you can change the stroke color
            shapeLayer.strokeColor = UIColor.redColor().CGColor
            //you can change the line width
            shapeLayer.lineWidth = 3.0
            
            view.layer.addSublayer(shapeLayer)
            break
            
        case 11:
            shapeLayer.removeFromSuperlayer()
            self.hide()
            imageView.image = UIImage(named: "account")
            self.secondLabel.text = accountSec
            self.secondLabel.hidden = false
            
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: 339,y: 634), radius: CGFloat(24), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
            
            
            shapeLayer.path = circlePath.CGPath
            
            //change the fill color
            shapeLayer.fillColor = UIColor.clearColor().CGColor
            //you can change the stroke color
            shapeLayer.strokeColor = UIColor.redColor().CGColor
            //you can change the line width
            shapeLayer.lineWidth = 3.0
            
            view.layer.addSublayer(shapeLayer)
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
