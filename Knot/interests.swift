//
//  interests.swift
//  Knot
//
//  Created by Nathan Mueller on 4/20/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit

class Interests: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var colView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descripText: UITextView!
    var interests = ["Electronics", "Cars and Motors", "Sports", "Toys", "Video Games", "Fashion", "Baby and Kids", "Books", "Furniture", "Art and Home Decor", "Tools", "Movies and Music"]
    var selected: Array<String>!
    
    @IBOutlet weak var DoneButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interests.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.selected.append(interests[indexPath.row])
        var cell : UICollectionViewCell = collectionView.cellForItemAtIndexPath(indexPath)!
        cell.backgroundColor = UIColor.yellowColor()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("InterestsCell", forIndexPath: indexPath) as! InterestsCell
        
        cell.cellLabel.text = self.interests[indexPath.row]
        
        UICollectionViewCell.animateWithDuration(0.25, animations: { cell.alpha = 1 })
        
        
        return cell
    }

    @IBAction func doneButton(sender: AnyObject) {
        if selected.count < 5 {
            var alert = UIAlertView(title: "Not Enough Selections", message: "Please select at least 5 interests", delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        }
        else {
            var interestString = ""
            for interest in selected {
                interestString = interestString + interest + ","
            }
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
