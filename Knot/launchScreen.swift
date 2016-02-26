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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().statusBarHidden=true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor(patternImage: self.imageLayerForGradientBackground())
        //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
        
        var path: UIBezierPath = UIBezierPath()
        path.moveToPoint(CGPointMake(76, 407))
        path.addLineToPoint(CGPointMake(130, 326))
        
        // Create a CAShape Layer
        var pathLayer: CAShapeLayer = CAShapeLayer()
        pathLayer.frame = self.view.bounds
        pathLayer.path = path.CGPath
        pathLayer.strokeColor = UIColor.whiteColor().CGColor
        pathLayer.fillColor = nil
        pathLayer.lineWidth = 2.0
        pathLayer.lineJoin = kCALineJoinBevel
        
        // Add layer to views layer
        self.view.layer.addSublayer(pathLayer)
        
        // Basic Animation
        var pathAnimation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = 0.5
        pathAnimation.fromValue = NSNumber(float: 0.0)
        pathAnimation.toValue = NSNumber(float:1.0)
        
        // Add Animation
        pathLayer.addAnimation(pathAnimation, forKey: "strokeEnd")
        
        var delayInSeconds = 0.5;
        var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            //2
            path = UIBezierPath()
            path.moveToPoint(CGPointMake(130, 326))
            path.addLineToPoint(CGPointMake(232, 390))
            
            // Create a CAShape Layer
            pathLayer = CAShapeLayer()
            pathLayer.frame = self.view.bounds
            pathLayer.path = path.CGPath
            pathLayer.strokeColor = UIColor.whiteColor().CGColor
            pathLayer.fillColor = nil
            pathLayer.lineWidth = 2.0
            pathLayer.lineJoin = kCALineJoinBevel
            
            // Add layer to views layer
            self.view.layer.addSublayer(pathLayer)
            
            // Basic Animation
            pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 0.5
            pathAnimation.fromValue = NSNumber(float: 0.0)
            pathAnimation.toValue = NSNumber(float:1.0)
            
            // Add Animation
            pathLayer.addAnimation(pathAnimation, forKey: "strokeEnd")
            
            delayInSeconds = 0.5;
            popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
            dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                
                //3
                path = UIBezierPath()
                path.moveToPoint(CGPointMake(232, 390))
                path.addLineToPoint(CGPointMake(300, 286))
                
                // Create a CAShape Layer
                pathLayer = CAShapeLayer()
                pathLayer.frame = self.view.bounds
                pathLayer.path = path.CGPath
                pathLayer.strokeColor = UIColor.whiteColor().CGColor
                pathLayer.fillColor = nil
                pathLayer.lineWidth = 2.0
                pathLayer.lineJoin = kCALineJoinBevel
                
                // Add layer to views layer
                self.view.layer.addSublayer(pathLayer)
                
                // Basic Animation
                pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
                pathAnimation.duration = 0.7
                pathAnimation.fromValue = NSNumber(float: 0.0)
                pathAnimation.toValue = NSNumber(float:1.0)
                
                // Add Animation
                pathLayer.addAnimation(pathAnimation, forKey: "strokeEnd")
                
                delayInSeconds = 0.5;
                popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
                dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
                    
                    //self.presentViewController(vc, animated: true, completion: nil)
                    
                    self.performSegueWithIdentifier("startApp", sender: self)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        if (segue!.identifier == "startApp") {
            appDelegate.startApp = true
            let viewController:HomeTabBarController = segue!.destinationViewController as! HomeTabBarController
            //viewController.startApp = true
        }
    }
    
    private func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.view.bounds
        // take into account the status bar
        updatedFrame.size.height += 20
        var layer = CAGradientLayer.gradientLayerForBounds(updatedFrame)
        UIGraphicsBeginImageContext(layer.bounds.size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
