//
//  FinderListCell.h
//  LifeLog
//
//  Created by cliff on 11. 3. 18..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListCell : UITableViewCell {

}

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, retain) IBOutlet UIImageView *ratingScoreImage;
@property (nonatomic, retain) IBOutlet UILabel *feelingLabel;
@property (nonatomic, retain) IBOutlet UILabel *contentLabel;
@property (nonatomic, retain) IBOutlet UIImageView *mapYnImage;
@property (nonatomic, retain) IBOutlet UIImageView *facebookYnImage;
@property (nonatomic, retain) IBOutlet UIImageView *line1Image;
@property (nonatomic, retain) IBOutlet UIImageView *line2Image;
@property (nonatomic, retain) IBOutlet UIImageView *accessoryImage;

@end
