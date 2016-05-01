//
//  collection.swift
//  Knot
//
//  Created by Nathan Mueller on 3/30/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation

//collection item: a future feature
class CollectionItem : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var ID   : String = "placeholder"
    var name  : String = "placeholder"
    var price   : String = "placeholder"
    var location : String = "placeholder"
    var time : String = "placeholder"
    var creator : String = "placehoder"
    var creatorFBID : String = "placeholder"
    var descriptionKnot : String = "placeholder"
    var category : String = "placeholder"
    var numberOfPics : Int = 1
    var sellerSBID : String = "0"
    var forks : Int = 0
    var suggestionsAllowed : Bool = false
    var userListings : [String] = []
    var onlineListings : [String] = []
    var storeListings : [String] = []
    
    
    /*
     override init!() { super.init() }
     
     required init!(coder: NSCoder!) {
     fatalError("init(coder:) has not been implemented")
     }
     */
    class func dynamoDBTableName() -> String! {
        return "knot-collections"
    }
    class func hashKeyAttribute() -> String! {
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