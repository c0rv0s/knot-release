//
//  AuthScreen.swift
//  Knot
//
//  Created by Nathan Mueller on 4/26/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import UIKit
import CoreLocation
import LocalAuthentication
import AVKit
import AVFoundation
import WebKit

class AuthScreen: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, WKNavigationDelegate, PKPaymentAuthorizationViewControllerDelegate {

    let picker = UIImagePickerController()
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var webView: WKWebView?
    
    @IBOutlet weak var IntroText: UITextView!
    
    @IBOutlet weak var ImgTwo: UIImageView!
    @IBOutlet weak var ImgOne: UIImageView!
    @IBOutlet weak var ImgButtonOne: UIButton!
    @IBOutlet weak var ImgButtonTwo: UIButton!
    
    var photoNum = 0
    var fee = 0.01
    
    var item : ListItem!
    var cogID : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.picker.delegate = self
        item  = self.appDelegate.item
        print(item.name)
        
        self.IntroText.editable = false
        
        cogID = self.appDelegate.cognitoId! as String
        
        fee = Double(appDelegate.item.price)! * 0.04
        
        // Creating actual WebView object. You can make it accessible
        // globally and used by other view controllers / objects
        webView = WKWebView()

        // Adding subview to the current interface. It’s not visible.
        view.addSubview(webView!)
        
        //load the url and call the init function for creating the contract
        let url = NSBundle.mainBundle().URLForResource("web3", withExtension:"html")
        webView!.loadRequest(NSURLRequest(URL: url!))
        webView!.navigationDelegate = self
        
        
    }
    // Called when web-page is loaded
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!)
    {
        print("Web.js is here!")
        webView.evaluateJavaScript("web3.isConnected()", completionHandler: {(res: AnyObject?, error: NSError?) in
            if let connected = res where connected as! NSInteger == 1
            {
                print("Connected to ethereum node")
            }
            else
            {
                print("Unable to connect to the node. Check the setup.")
            }
            
        })
    }
    
    @IBAction func DoneButton(sender: AnyObject) {
        //if (nameField.text == "Test" || nameField.text == "test" || nameField.text == "Demo" || nameField.text == "demo") {
        
        //}
        //else {
            //apple pay
            
            guard let request = Stripe.paymentRequestWithMerchantIdentifier("merchant.com.knotcomplex") else {
                // request will be nil if running on < iOS8
                return
            }
            request.paymentSummaryItems = [
                PKPaymentSummaryItem(label: "Authorization for \(self.item.name)", amount: NSDecimalNumber(double: self.fee))
            ]
            
            if (Stripe.canSubmitPaymentRequest(request)) {
                print("success!")
                let paymentController = PKPaymentAuthorizationViewController(paymentRequest: request)
                presentViewController(paymentController, animated: true, completion: nil)
            } else {
                // Show the user your own credit card form (see options 2 or 3)
                print("derp")
            }
       // }
        
    }
    
    @IBAction func ImgButtonOne(sender: AnyObject) {
        self.photoNum = 1
        self.showCamera()
    }
    
    @IBAction func ImgButtonTwo(sender: AnyObject) {
        self.photoNum = 2
        self.showCamera()
    }
    
    func showCamera() {
        let alert = UIAlertController(title: "Select Option:", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (alertAction) -> Void in
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                self.picker.allowsEditing = false
                self.picker.sourceType = UIImagePickerControllerSourceType.Camera
                self.picker.cameraCaptureMode = .Photo
                self.picker.modalPresentationStyle = .FullScreen
                self.presentViewController(self.picker,
                    animated: true,
                    completion: nil)
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Photos", style: .Default, handler: { (alertAction) -> Void in
            self.picker.allowsEditing = true
            self.picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.picker.modalPresentationStyle = .FullScreen
            self.presentViewController(self.picker,
                animated: true,
                completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (alertAction) -> Void in }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            picker.modalPresentationStyle = .FullScreen
            presentViewController(picker,
                                  animated: true,
                                  completion: nil)
        }
    }
    
    //MARK: - Delegates
    //What to do when the picker returns with a photo
    func imagePickerController(picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : AnyObject]){
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        let bucket = "authentication-docs"

        if photoNum == 1 {
            ImgOne.image = self.cropToSquare(image: chosenImage)
            let ID = self.item.ID + "-1"
            //upload pic
            let testFileURL1 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let dataOne = UIImageJPEGRepresentation(self.resizeImage(chosenImage), 0.5)
            dataOne!.writeToURL(testFileURL1, atomically: true)
            uploadRequest1.bucket = bucket
            uploadRequest1.key = ID
            uploadRequest1.body = testFileURL1
            let task1 = transferManager.upload(uploadRequest1)
            task1.continueWithBlock { (task: AWSTask!) -> AnyObject! in
                if task1.error != nil {
                    print("Error: \(task1.error)")
                } else {
                    print("photo one done")
                }
                return nil
            }
            //done uploading
           
        }
        if photoNum == 2 {
            let ID = self.item.ID + "-2"
            ImgTwo.image = self.cropToSquare(image: chosenImage)
            
            //do second photo
            let testFileURL2 = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("temp"))
            let uploadRequest2 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
            let dataTwo = UIImageJPEGRepresentation(self.resizeImage(chosenImage), 0.5)
            dataTwo!.writeToURL(testFileURL2, atomically: true)
            uploadRequest2.bucket = bucket
            uploadRequest2.key = ID
            uploadRequest2.body = testFileURL2
            let task2 = transferManager.upload(uploadRequest2)
            task2.continueWithBlock { (task: AWSTask!) -> AnyObject! in
                if task2.error != nil {
                    print("Error: \(task2.error)")
                } else {
                    print("photo two done")
                }
                return nil
            }
            //second photo done
        }
        dismissViewControllerAnimated(true, completion: nil) //5
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true,
                                      completion: nil)
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        var actualHeight = CGFloat(image.size.height)
        var actualWidth = CGFloat(image.size.width)
        let maxHeight = CGFloat(1000.0)
        let maxWidth = CGFloat(600.00)
        var imgRatio = CGFloat(actualWidth/actualHeight)
        let maxRatio = CGFloat(maxWidth/maxHeight)
        let compressionQuality = CGFloat(0.25)//25 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        //[image drawInRect:rect];
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return UIImage(data:imageData!)!
        
    }
    
    
    @IBAction func cancelButton(sender: AnyObject) {
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller")
        self.presentViewController(vc, animated: true, completion: nil)
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
    
    //touch id
    func showPasswordAlert() {
    }
    
    func authenticateUser() {
        /***CONVERT FROM NSDate to String ****/
        /*
        
        
        let context : LAContext = LAContext()
        var error : NSError?
        let myLocalizedReasonString : NSString = "Authenticate your item with Touch ID"
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString as String, reply: { (success : Bool, evaluationError : NSError?) -> Void in
                if success {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
 */
                        self.loadData(true)
                        
                        //create a contract
                        //This "res" may contains an address to contract, but this is not returned immidately.
                        //so far, it created successfully, but it spends long time to get address because mine speed is too slow.
                        //for test, address is defined manually right now.
                        //In public chain, we can get address in 30 seconds, but this is also too slow.
                        //we need to make some empty contacts before this process and stock them.
                        let contractAddress: String = "0x5528ddffca8c3de266aa020f87139dd0d5e3163a"
                        self.webView!.evaluateJavaScript("contractmaker()",
                            completionHandler: {(res: AnyObject?, error: NSError?) in
                                print(error)
                                print(res)
                                //contractAddress = res
                                
                        })
                        
                        //init the contract
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "ddMMyyyyHHmmss"
                        //we need string, not Int.
                        let dateString = String(dateFormatter.stringFromDate(NSDate()))
                        /*self.webView!.evaluateJavaScript("contract.renewtimestamp.sendTransaction(\(dateString), {from: \"0xc8ca03fd80f08188520422431853b382e0df348e\", gas: 900000})",
                         completionHandler: {(res: AnyObject?, error: NSError?) in
                         print(error)
                         print(res)
                         })*/
                        self.webView!.evaluateJavaScript("contractinit(\"\(contractAddress)\",\"\(self.item.ID)\",\"\(self.cogID)\",\(dateString))",
                            completionHandler: {(res: AnyObject?, error: NSError?) in
                                print(error)
                                print(res)
                        })
                        /*
                    })
    
                }
                else {
                    // Authentification failed
                    print(evaluationError?.localizedDescription)
                    
                    switch evaluationError!.code {
                    case LAError.SystemCancel.rawValue:
                        print("Authentication cancelled by the system")
                    case LAError.UserCancel.rawValue:
                        print("Authentication cancelled by the user")
                    case LAError.UserFallback.rawValue:
                        print("User wants to use a password")
                        // We show the alert view in the main thread (always update the UI in the main thread)
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    default:
                        print("Authentication failed")
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.showPasswordAlert()
                        })
                    }
                }
            })
            
        }
        else {
            switch error!.code {
            case LAError.TouchIDNotEnrolled.rawValue:
                print("TouchID not enrolled")
            case LAError.PasscodeNotSet.rawValue:
                print("Passcode not set")
            default:
                print("TouchID not available")
            }
            self.showPasswordAlert()
        }
 */
    }
    //end touch id
    
    func insertItem(uniqueID: String, auth: Bool) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        item.authenticated = 1

        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }
    
    func wrapUpSubmission(succ1: Int, succ2: Int, succ3: Int) {
        print("Upload successful")
        let alertString = "Congratulations on authenticating your item! This will be listed in the Knot Store in a few moments."
        let alert = UIAlertController(title: "Success", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Awesome!", style: .Default, handler: { (alertAction) -> Void in
            //let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller")
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("CCInfo")
            self.presentViewController(vc, animated: true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
        self.appDelegate.mixpanel!.track?("Item Upload",
            properties: ["userID": self.appDelegate.cognitoId!, "item": self.item.ID]
        )
        
        self.appDelegate.mixpanel!.people.increment(
            [ "Listings": 1]
        )
    }
    
    //stripe code, coming next round
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        /*
         We'll implement this method below in 'Creating a single-use token'.
         Note that we've also been given a block that takes a
         PKPaymentAuthorizationStatus. We'll call this function with either
         PKPaymentAuthorizationStatusSuccess or PKPaymentAuthorizationStatusFailure
         after all of our asynchronous code is finished executing. This is how the
         PKPaymentAuthorizationViewController knows when and how to update its UI.
         */
        handlePaymentAuthorizationWithPayment(payment, completion: completion)
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        self.authenticateUser()
        dismissViewControllerAnimated(true, completion: nil)
        var delayInSeconds = 0.25;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier("Reveal View Controller") as! UIViewController
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    func handlePaymentAuthorizationWithPayment(payment: PKPayment, completion: PKPaymentAuthorizationStatus -> ()) {
        STPAPIClient.sharedClient().createTokenWithPayment(payment) { (token, error) -> Void in
            if error != nil {
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            /*
             We'll implement this below in "Sending the token to your server".
             Notice that we're passing the completion block through.
             See the above comment in didAuthorizePayment to learn why.
             */
            self.createBackendChargeWithToken(token!, completion: completion)
        }
    }
    
    func createBackendChargeWithToken(token: STPToken, completion: PKPaymentAuthorizationStatus -> ()) {
        
        let url = NSURL(string: "https://xr0qhxlt19.execute-api.us-east-1.amazonaws.com/prod/KnotStripeAccess")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let bodyOne = "{\"stripeToken\": \""  + token.tokenId
        let bodyTwo = "\",\n\"amount_cent\": \"\(self.fee)"
        let bodyThree = "\",\n\"currency\": \"usd\",\n\"description\": \"test\"}"
        let body = bodyOne + bodyTwo + bodyThree
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if error != nil {
                completion(PKPaymentAuthorizationStatus.Failure)
            }
            else {
                completion(PKPaymentAuthorizationStatus.Success)
            }
        }
        task.resume()
    }
    //end stripe
    
    func loadData(auth: Bool) {
    
        UIApplication.sharedApplication().statusBarHidden = false
        //SwiftSpinner.show("Uploading...")
        print("begin auth doc post")
        //update the authenticated data point on Dynamo to say true
        if (item.name == "Test" || item.name == "test" || item.name == "Demo" || item.name == "demo") {}
        else {
            self.insertItem(self.item.ID, auth: auth).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        }
        //self.wrapUpSubmission(0, succ2: 0, succ3: 0)
    }
    
    
    @IBAction func examplesButton(sender: AnyObject) {
        if let url = NSURL(string: "http://www.knotcomplex.com/Auth-Help.html") {
            UIApplication.sharedApplication().openURL(url)
        }
    }

}
  