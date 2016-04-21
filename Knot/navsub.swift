//
//  navsub.swift
//  Knot
//
//  Created by Nathan Mueller on 2/9/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import UIKit

class navsub: UINavigationController {
    
    //let tintColor = UIColor(red: 1, green: 175/255, blue: 35/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationBar.translucent = false
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.barTintColor = UIColor(red: 1, green: 175/255, blue: 35/255, alpha: 1)

        //let fontDictionary = [ NSForegroundColorAttributeName:UIColor.whiteColor() ]
        //self.navigationBar.titleTextAttributes = fontDictionary
        //self.navigationBar.setBackgroundImage(UIColor(red: 1, green: 175/255, blue: 35/255, alpha: 1), forBarMetrics: UIBarMetrics.Default)
    }
    
    private func imageLayerForGradientBackground() -> UIImage {
        
        var updatedFrame = self.navigationBar.bounds
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
