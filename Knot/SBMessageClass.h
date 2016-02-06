//
//  SBMessageClass.h
//  Knot
//
//  Created by Nathan Mueller on 2/1/16.
//  Copyright © 2016 Knot App. All rights reserved.
//

#ifndef SBMessageClass_h
#define SBMessageClass_h


#import "SendBird/MessagingTableViewController.h"
#import <SendBirdSDK/SendBirdSDK.h>


@interface SBMessageClass : NSObject

//UINavigationController navigationController;

- (void)startSendBirdMessaging;
- (void)startSendBirdMessagingTarget;

@end

#endif /* SBMessageClass_h */
