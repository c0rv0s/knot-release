//
//  messaging.swift
//  Knot
//
//  Created by Nathan Mueller on 1/27/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

import UIKit
import SendBirdSDK

class Messaging: UIViewController, UITextFieldDelegate {
    var sendbirdLogoImageView: UIImageView?
    var sendbirdLabel: UILabel?
    var backgroundImageView: UIImageView?
    var sendbirdStartOpenChatButton: UIButton?
    var sendbirdStartMessaging: UIButton?
    var sendbirdMemberListButton: UIButton?
    var sendbirdMessagingChannelList: UIButton?
    var sendbirdBackFromMessaging: UIButton?
    var sendbirdChannelListButton: UIButton?
    var sendbirdLobbyMemberListButton: UIButton?
    var sendbirdMessagingChannelListButton: UIButton?
    var sendbirdUserNicknameLabel: UILabel?
    var sendbirdUserNicknameTextField: UITextField?
    
    private var messagingUserName: NSString?
    private var messagingUserId: NSString?
    var messagingTargetUserId: NSString = ""
    private var startMessagingFromOpenChat: Bool?
    
    var SendBirdUserID = ""
    
    var cognitoID = ""
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var userName = ""
    
    var viewMode = kMessagingChannelListViewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //user id stuff
        if self.appDelegate.loggedIn {}
        else {
            let alert = UIAlertController(title:"Attention", message: "You need to sign in to access these features", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Never Mind", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("MainRootView") as! UITabBarController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Sign In", style: .Default, handler: { (alertAction) -> Void in
                let vc = self.storyboard!.instantiateViewControllerWithIdentifier("LoginView") as! UIViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }))
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        setTabBarVisible(true, animated: true)
        
        // Retrieve your Amazon Cognito ID
        
        appDelegate.credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
                
            } else {
                // the task result will contain the identity id
                self.cognitoID = task.result as! String
            }
            return nil
        }
        
        //fetch SendBird ID
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("profileInfo")
        let value = dataset.stringForKey("SBID")
        self.userName = dataset.stringForKey("name")
        self.SendBirdUserID = value
        
        NSLog("launching the channel list view :D:D:D:D:D")
        self.startSendBird(self.userName, chatMode: kChatModeMessaging, viewMode: self.viewMode)

        //self.initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "startMessagingWithUser:", name: "open_messaging", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.startMessagingFromOpenChat == true {
            let viewController: MessagingTableViewController = MessagingTableViewController()
            viewController.setViewMode(kMessagingViewMode)
            viewController.initChannelTitle()
            viewController.channelUrl = ""
            viewController.userName = self.messagingUserName
            viewController.userId = self.messagingUserId
            viewController.targetUserId = self.messagingTargetUserId
            
            let navigationController: UINavigationController = UINavigationController.init(rootViewController: viewController)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
        
        self.startMessagingFromOpenChat = false
    }
    
    private func startMessagingWithUser(obj: NSNotification) {
        self.messagingTargetUserId = obj.object as! String
        self.startMessagingFromOpenChat = true
    }
    
    func clickSendBirdStartOpenChatButton(sender: AnyObject) {
        NSLog("clickSendBirdStartOpenChatButton")
        if self.sendbirdUserNicknameTextField?.text?.characters.count > 0 {
            self.startSendBird((self.sendbirdUserNicknameTextField?.text)!, chatMode: kChatModeChatting, viewMode: kChannelListViewMode)
        }
    }
    
    func clickSendBirdStartMessagingButton(sender: AnyObject) {
        NSLog("clickSendBirdStartMessagingButton")
        self.sendbirdStartOpenChatButton?.hidden = true
        self.sendbirdStartMessaging?.hidden = true
        self.sendbirdMemberListButton?.hidden = false
        self.sendbirdMessagingChannelListButton?.hidden = false
        self.sendbirdBackFromMessaging?.hidden = false
    }
    
    func clickSendBirdMemberListButton(sender: AnyObject) {
        //setTabBarVisible(!tabBarIsVisible(), animated: true)
        NSLog("clickSendBirdMemberListButton")
        if self.sendbirdUserNicknameTextField?.text?.characters.count > 0 {
            self.startSendBird((self.sendbirdUserNicknameTextField?.text)!, chatMode: kChatModeMessaging, viewMode: kMessagingMemberViewMode)
        }
    }
    
    func clickSendBirdMessagingChannelListButton(sender: AnyObject) {
        //setTabBarVisible(!tabBarIsVisible(), animated: true)
        NSLog("clickSendBirdMessagingChannelListButton")
        if self.sendbirdUserNicknameTextField?.text?.characters.count > 0 {
            self.startSendBird((self.sendbirdUserNicknameTextField?.text)!, chatMode: kChatModeMessaging, viewMode: kMessagingChannelListViewMode)
        }
    }
    
    func clickSendBirdBackFromMessaging(sender: AnyObject) {
        NSLog("clickSendBirdBackFromMessaging")
        self.sendbirdStartOpenChatButton?.hidden = false
        self.sendbirdStartMessaging?.hidden = false
        self.sendbirdMemberListButton?.hidden = true
        self.sendbirdMessagingChannelListButton?.hidden = true
        self.sendbirdBackFromMessaging?.hidden = true
    }
    
    private func startSendBird(userName: String, chatMode: Int, viewMode: Int) {
        let APP_ID: String = "6D1F1F00-D8E0-4574-A738-4BDB61AF0411"
        let USER_ID: String = self.SendBirdUserID
        let USER_NAME: String = userName
        
        print("SendBirdUserID = " + USER_ID)
        
        self.messagingUserName = USER_NAME
        self.messagingUserId = USER_ID
            let viewController: MessagingTableViewController = MessagingTableViewController()
            SendBird.initAppId(APP_ID, withDeviceId: USER_ID)
            
            viewController.setViewMode(viewMode)
            viewController.initChannelTitle()
            viewController.userName = USER_NAME
            viewController.userId = USER_ID
            viewController.targetUserId = self.messagingTargetUserId
            
            self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //tab bar methods
    func setTabBarVisible(visible:Bool, animated:Bool) {
        
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        // bail if the current state matches the desired state
        if (tabBarIsVisible() == visible) { return }
        
        // get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // zero duration means no animation
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
        //  animate the tabBar
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }
}

