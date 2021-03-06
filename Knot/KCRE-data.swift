//
//  KCRE-data.swift
//  Knot
//
//  Created by Nathan Mueller on 3/30/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

//KCRE data points, to be used
class KCREData : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
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
        return "KCRE-data"
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