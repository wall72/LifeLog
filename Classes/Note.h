//
//  Note.h
//  LifeLog
//
//  Created by cliff on 11. 4. 12..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Resource;

@interface Note : NSManagedObject {

@private

}

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * user_uuid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSNumber * published;
@property (nonatomic, retain) NSString * feeling;
@property (nonatomic, retain) NSNumber * rating_score;
@property (nonatomic, retain) NSString * log_time;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSNumber * daily_yn;
@property (nonatomic, retain) NSNumber * facebook_yn;
@property (nonatomic, retain) NSNumber * twitter_yn;
@property (nonatomic, retain) NSNumber * map_yn;
@property (nonatomic, retain) NSNumber * image_yn;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * update_count;
@property (nonatomic, retain) NSNumber * created_time;
@property (nonatomic, retain) NSNumber * updated_time;
@property (nonatomic, retain) NSSet* resources;
@property (nonatomic, retain) NSString * sectionIdentifier;

@end
