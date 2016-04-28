//
//  new-stars.swift
//  Knot
//
//  Created by Nathan Mueller on 4/27/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

class NewStars : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var userID   : String = "placeholder"
    var raterID : String = "placeholder"
    var stars : Int = 5
    var timestamp  : String = "placeholder"
    var comment : String = "placeholder"
    
    
    /*
     override init!() { super.init() }
     
     required init!(coder: NSCoder!) {
     fatalError("init(coder:) has not been implemented")
     }
     */
    class func dynamoDBTableName() -> String! {
        return "star-ratings"
    }
    class func hashKeyAttribute() -> String! {
        return "userID"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "raterID"
    }
    
    /*
     //required to let DynamoDB Mapper create instances of this class
     init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
     super.init(dictionary: dictionaryValue, error: error)
     }
     */
    override func isEqual(object: AnyObject?) -> Bool { return super.isEqual(object) }
    override func `self`() -> Self { return self }
}