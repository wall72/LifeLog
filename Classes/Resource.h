//
//  Resource.h
//  LifeLog
//
//  Created by cliff on 11. 4. 12..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Note;

@interface Resource : NSManagedObject {

@private

}

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSString *user_uuid;
@property (nonatomic, retain) NSString *note_uuid;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *mime;
@property (nonatomic, retain) NSString *file_name;
@property (nonatomic, retain) NSString *file_id;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSNumber *file_size;
@property (nonatomic, retain) NSNumber *display_sequence;
@property (nonatomic, retain) NSNumber *active;
@property (nonatomic, retain) NSNumber *update_count;
@property (nonatomic, retain) NSNumber *created_time;
@property (nonatomic, retain) NSNumber *updated_time;
@property (nonatomic, retain) Note * note;

@end
