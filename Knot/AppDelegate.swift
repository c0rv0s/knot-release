//
//  AppDelegate.swift
//  Knot
//
//  Created by Nathan Mueller on 11/15/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    var window: UIWindow?
    var credentialsProvider = AWSCognitoCredentialsProvider()
    var cognitoId: AnyObject?
    
    //location
    var locationManager: OneShotLocationManager!
    var locCurrent: CLLocation!
    
    var startApp = false
    var untapped: Array<String>!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UINavigationBar.appearance().barStyle = .Black
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        // Initialize the Amazon Cognito credentials provider
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
            identityPoolId:"us-east-1:353ba7a2-f7d3-4d16-8064-61bd93fdee7c")

        
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        Instabug.startWithToken("78c16dde6a35093640aa82c7114f0526", invocationEvent: IBGInvocationEventShake)

        /*
        AWSMobileAnalytics *analytics = [AWSMobileAnalytics
            mobileAnalyticsForAppId: @"8a8ff18d8fa242df8a62add92ba837ab" //Amazon Mobile Analytics App ID
        identityPoolId: @"us-east-1:249a3e7c-13c2-4289-9ef2-2467fd930e4f"] //Amazon Cognito Identity Pool ID
*/
        /*
        //calculate distance
        //remember to switch this b4 release
        locationManager = OneShotLocationManager()
        locationManager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                self.locCurrent = loc
            } else if let err = error {
                print(err.localizedDescription)
            }
            self.locationManager = nil
        }
*/
        self.locCurrent = CLLocation(latitude: 37.3653032084585, longitude: -122.133118002751)
        
        untapped = []
        
        //return facebook data
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject?) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(
                application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    //notifications
    func initializeNotificationServices() -> Void {
        let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        // ...register device token with our Time Entry API server via REST
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Device token for push notifications: FAIL -- ")
        print(error.description)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // display the userInfo
        if let notification = userInfo["aps"] as? NSDictionary,
            let alert = notification["alert"] as? String {
                var alertCtrl = UIAlertController(title: "Test", message: alert as String, preferredStyle: UIAlertControllerStyle.Alert)
                alertCtrl.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                // Find the presented VC...
                var presentedVC = self.window?.rootViewController
                while (presentedVC!.presentedViewController != nil)  {
                    presentedVC = presentedVC!.presentedViewController
                }
                presentedVC!.presentViewController(alertCtrl, animated: true, completion: nil)
                
                // call the completion handler
                // -- pass in NoData, since no new data was fetched from the server.
                completionHandler(UIBackgroundFetchResult.NoData)
        }
    }

    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        //  Convert binary Device Token to a String (and remove the <,> and white space charaters).
        var deviceTokenStr = deviceToken.description.stringByReplacingOccurrencesOfString(">", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString("<", withString: "")
        deviceTokenStr = deviceTokenStr.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        // Our API returns token in all uppercase, regardless how it was originally sent.
        // To make the two consistent, I am uppercasing the token string here.
        deviceTokenStr = deviceTokenStr.uppercaseString
        return deviceTokenStr
    }

    //end notifications
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //TODO: only one item makes it in since they all have the same time, fix this!
        //upload untapped items
        //collect view info
        for item in untapped {
            self.dataStash(item, itemCondition: 3).continueWithBlock({
                (task: BFTask!) -> BFTask! in
                
                if (task.error != nil) {
                    print(task.error!.description)
                } else {
                    print("DynamoDB save succeeded")
                }
                
                return nil;
            })
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "KnotApp.Knot" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Knot", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as! NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //store user data
    func dataStash(itemId: String, itemCondition: Int) -> BFTask! {
        let mapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        var cogID = ""
        credentialsProvider.getIdentityId().continueWithBlock { (task: AWSTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error: " + task.error!.localizedDescription)
            }
            else {
                // the task result will contain the identity id
                cogID = task.result as! String
            }
            return nil
        }
        
        /***CONVERT FROM NSDate to String ****/
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateString = dateFormatter.stringFromDate(NSDate())
        
        let item = sessionData()
        item.userID = cogID
        item.itemID = itemId
        item.timestamp = dateString
        item.status = itemCondition
        
        print(item)
        let task = mapper.save(item)
        
        print("item created, preparing upload")
        return BFTask(forCompletionOfAllTasks: [task])
    }

}

