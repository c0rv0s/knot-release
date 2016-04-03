//
//  pageController.swift
//  Knot
//
//  Created by Nathan Mueller on 3/24/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import Foundation
import UIKit

class pageController: UIViewController, UIScrollViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    
    var pic : UIImage!
    var picTwo : UIImage!
    var picThree : UIImage!
    
    var DetailItem  : ListItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pic = UIImage(named: "placeholder-1")
        picTwo = UIImage(named: "placeholder-1")
        picThree = UIImage(named: "placeholder-1")
        
        //grab pictures
        self.downloadImage(DetailItem.ID, photoNum: 1)
        
         if self.DetailItem.numberOfPics > 1 {
            self.downloadImage(self.DetailItem.ID, photoNum: 2)
            if self.DetailItem.numberOfPics > 2 {
                self.downloadImage(self.DetailItem.ID, photoNum: 3)
            }
         }
        
        // 1
        pageImages = [pic, picTwo, picThree]
        
        let pageCount = pageImages.count
        
        // 2
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        // 3
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        
        // 4
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count),
                                        height: pagesScrollViewSize.height)
        
        // 5
        loadVisiblePages()
    }
    
    func loadPage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // 1
        if let pageView = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            // 2
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
            
            // 3
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            scrollView.addSubview(newPageView)
            
            // 4
            pageViews[page] = newPageView
        }
    }
    
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page + 1
        
        // Purge anything before the first page
        for var index = 0; index < firstPage; ++index {
            purgePage(index)
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        for var index = lastPage+1; index < pageImages.count; ++index {
            purgePage(index)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView!) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
    
    
    
    func downloadImage(key: String, photoNum: Int){
        
        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
        
        //downloading image
        var S3BucketName : String!
        if photoNum == 1 {
            S3BucketName = "knotcompleximages"
        }
        if photoNum == 2 {
            S3BucketName = "knotcompleximage2"
        }
        if photoNum == 3 {
            S3BucketName = "knotcompleximage3"
        }
        let S3DownloadKeyName: String = key
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.downloadProgress = {(task: AWSS3TransferUtilityTask, bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) in
            dispatch_async(dispatch_get_main_queue(), {
                let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
                //self.progressView.progress = progress
                //   self.statusLabel.text = "Downloading..."
                NSLog("Progress is: %f",progress)
            })
        }
        
        completionHandler = { (task, location, data, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if ((error) != nil){
                    NSLog("Failed with error")
                    NSLog("Error: %@",error!);
                    //   self.statusLabel.text = "Failed"
                }
                    /*
                     else if(self.progressView.progress != 1.0) {
                     //    self.statusLabel.text = "Failed"
                     NSLog("Error: Failed - Likely due to invalid region / filename")
                     }   */
                else{
                    var newPic = self.cropToSquare(image: UIImage(data: data!)!)
                    if photoNum == 1 {
                        self.pic = newPic
                        //self.itemPic.image = newPic
                    }
                    if photoNum == 2 {
                        self.picTwo = newPic
                    }
                    if photoNum == 3 {
                        self.picThree = newPic
                    }
                }
            })
        }
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        
        transferUtility.downloadToURL(nil, bucket: S3BucketName, key: S3DownloadKeyName, expression: expression, completionHander: completionHandler).continueWithBlock { (task) -> AnyObject! in
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
                //  self.statusLabel.text = "Failed"
            }
            if let exception = task.exception {
                NSLog("Exception: %@",exception.description);
                //  self.statusLabel.text = "Failed"
            }
            if let _ = task.result {
                //    self.statusLabel.text = "Starting Download"
                //NSLog("Download Starting!")
                // Do something with uploadTask.
            }
            return nil;
        }
        
    }
    
    func cropToSquare(image originalImage: UIImage) -> UIImage {
        // Create a copy of the image without the imageOrientation property so it is in its native orientation (landscape)
        let contextImage: UIImage = UIImage(CGImage: originalImage.CGImage!)
        
        // Get the size of the contextImage
        let contextSize: CGSize = contextImage.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height of our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(CGImage: imageRef, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        return image
    }

}