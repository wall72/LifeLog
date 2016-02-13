//
//  DailyListViewController.h
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DailyListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	
}

@property (nonatomic, retain) UIView *daySumbar;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSDateComponents *curDate;
@property (nonatomic, retain) NSMutableArray *array48hour;
@property (nonatomic, retain) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger sumOfRating;
@property (nonatomic, assign) NSInteger sumOfFeeling;
@property (nonatomic, assign) NSInteger countOfNote;

- (void)refreshAfterSync;

@end
