//
//  MapViewMarker.m
//  LifeLog
//
//  Created by cliff on 11. 3. 24..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "MapViewMarker.h"
#import "Utils.h"

@implementation MapViewMarker

@synthesize coordinate = __coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

-(void) dealloc{
	NSLog(@"call");
    
    self.title = nil;
    self.subtitle = nil;
	[_title release];
	[_subtitle release];
	[super dealloc];
}

@end
