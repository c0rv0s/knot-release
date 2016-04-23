//
//  interests.swift
//  Knot
//
//  Created by Nathan Mueller on 4/20/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit

class Interests: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descripText: UITextView!
    var interests = ["Electronics", "Cars and Motors", "Sports", "Toys", "Video Games", "Fashion", "Baby and Kids", "Books", "Furniture", "Art and Home Decor", "Tools", "Movies and Music"]
    var selected: [Int:String]!
    
    
    @IBOutlet weak var DoneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selected = [:]
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 150, left: 0, bottom: 50, right: 0)
        layout.itemSize = CGSize(width: 120, height: 40)
        
        collectionView!.contentInset = UIEdgeInsets(top: 23, left: 5, bottom: 10, right: 5)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {return interests.count}
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InterestsCell", forIndexPath: indexPath) as! InterestsCell
        cell.cellLabel.text = self.interests[indexPath.row]
        cell.cellLabel.textColor = UIColor.blackColor()
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 1
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell?.backgroundColor == UIColor.lightGrayColor() {
            cell?.backgroundColor = UIColor.whiteColor()
            self.selected[indexPath.row] = nil
        }
        else {
            cell?.backgroundColor = UIColor.lightGrayColor()
            print(interests[indexPath.row])
            self.selected[indexPath.row] = interests[indexPath.row]
        }
    }


    @IBAction func doneButton(sender: AnyObject) {
        if selected.count < 5 {
            var alert = UIAlertView(title: "Not Enough Selections", message: "Please select at least 5 interests", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else {
            var interestString = ""
            for (key, value) in selected {
                interestString = interestString + value + ","
            }
            print(interestString)
            //upload profile
            let syncClient = AWSCognito.defaultCognito()
            let dataset = syncClient.openOrCreateDataset("profileInfo")
            
            dataset.setString(interestString, forKey:"interests")
            dataset.synchronize().continueWithBlock {(task) -> AnyObject! in
                return nil
            }

            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}


