//
//  NotificationTimeViewController.h
//  LifeLog
//
//  Created by cliff on 11. 3. 29..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTimeViewController : UITableViewController {
    
}

@property (nonatomic, retain) NSMutableDictionary *notiTimes;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, assign) BOOL flagNotification;

@end
