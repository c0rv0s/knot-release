//
//  gradientExtension.swift
//  Knot
//
//  Created by Nathan Mueller on 2/9/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    class func gradientLayerForBounds(bounds: CGRect) -> CAGradientLayer {
        let purple = UIColor(red: 160.65/255, green: 73.95/255, blue: 216.75/255, alpha: 1.0).CGColor
        let blue = UIColor(red: 56.1/255, green: 119.85/255, blue: 229.5/255, alpha: 1.0).CGColor
        var layer = CAGradientLayer()
        layer.frame = bounds
        layer.colors = [purple  , blue  ]
        return layer
    }
}