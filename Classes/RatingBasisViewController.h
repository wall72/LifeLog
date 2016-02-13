//
//  RatingBasisViewController.h
//  LifeLog
//
//  Created by cliff on 11. 4. 5..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingBasisViewController : UITableViewController {
    
}

@property (nonatomic, retain) NSMutableDictionary *ratingBasis;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;

@end
