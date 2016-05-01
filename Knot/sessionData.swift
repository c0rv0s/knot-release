//
//  sessionData.swift
//  Knot
//
//  Created by Nathan Mueller on 2/23/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

//user data for actions stored during the session get these to dynamo
class sessionData : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
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
        return "Training-Data"
    }
    class func hashKeyAttribute() -> String! {
        return "timestamp"
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