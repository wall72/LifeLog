//
//  TimeSpanViewController.h
//  LifeLog
//
//  Created by cliff on 11. 4. 6..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeSpanViewController : UITableViewController {
    
}

@property (nonatomic, retain) NSMutableDictionary *timeSpan;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

@end
