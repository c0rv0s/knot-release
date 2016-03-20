//
//  Bridging-Header.h
//  Knot
//
//  Created by Nathan Mueller on 11/26/15.
//  Copyright © 2015 Knot App. All rights reserved.
//

#ifndef Bridging_Header_h
#define Bridging_Header_h

//facebook
#import <Bolts/Bolts.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

//AWS
#import "AWSCore.h"
#import "AWSCognito.h"
#import <AWSMobileAnalytics/AWSMobileAnalytics.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

//Instabug
//#import <Instabug/Instabug.h>

//AFNetworking
//#import <AFNetworking/AFNetworking.h>
#import "AFNetworking.h"
#import "Mixpanel/Mixpanel.h"

//Sendbird
//#import "SBMessageClass.h"
//#import "MemberTableViewCell.h"

#endif /* Bridging_Header_h */
