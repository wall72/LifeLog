//
//  DetailViewController.h
//  LifeLog
//
//  Created by cliff on 11. 4. 7..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"

@class Note;

@interface DetailViewController : UIViewController <DLStarRatingDelegate> {
    
}

@property (nonatomic, retain) Note *note;

@end
