//
//  FinderListCell.m
//  LifeLog
//
//  Created by cliff on 11. 3. 18..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

@synthesize backgroundImage = _backgroundImage;
@synthesize ratingScoreImage = _ratingScoreImage;
@synthesize feelingLabel = _feelingLabel;
@synthesize contentLabel = _contentLabel;
@synthesize mapYnImage = _mapYnImage;
@synthesize facebookYnImage = _facebookYnImage;
@synthesize line1Image = _line1Image;
@synthesize line2Image = _line2Image;
@synthesize accessoryImage = _accessoryImage;

- (void)dealloc {
	NSLog(@"call");
	
    self.backgroundImage = nil;
    self.ratingScoreImage = nil;
    self.feelingLabel = nil;
    self.contentLabel = nil;
    self.mapYnImage = nil;
    self.facebookYnImage = nil;
    self.line1Image = nil;
    self.line2Image = nil;
    self.accessoryImage = nil;

    [_backgroundImage release];
    [_ratingScoreImage release];
    [_feelingLabel release];
    [_contentLabel release];
    [_mapYnImage release];
    [_facebookYnImage release];
    [_line1Image release];
    [_line2Image release];
    [_accessoryImage release];
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	NSLog(@"call");
	
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	NSLog(@"call");
    
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [self.contentView setBackgroundColor:[UIColor blueColor]];
        [self.backgroundImage setAlpha:0.6];
    } else {
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self.backgroundImage setAlpha:1.0];
    }
}

@end
