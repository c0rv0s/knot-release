//
//  KRE-data-2.0.swift
//  Knot
//
//  Created by Nathan Mueller on 3/23/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

//KRE data points
class KREData : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var userID   : String = "placeholder"
    var itemID : String = "placeholder"
    var timestamp  : String = "placeholder"
    var status   : Int = 0
    
    
    /*
     override init!() { super.init() }
     
     required init!(coder: NSCoder!) {
     fatalError("init(coder:) has not been implemented")
     }
     */
    class func dynamoDBTableName() -> String! {
        return "KRE-data-2.0"
    }
    class func hashKeyAttribute() -> String! {
        return "userID"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "itemID"
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