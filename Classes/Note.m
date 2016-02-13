//
//  Note.m
//  LifeLog
//
//  Created by cliff on 11. 4. 12..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "Note.h"
#import "Resource.h"
#import "Utils.h"
#import "Global.h"

@implementation Note

@dynamic uuid;
@dynamic user_uuid;
@dynamic title;
@dynamic active;
@dynamic published;
@dynamic feeling;
@dynamic rating_score;
@dynamic log_time;
@dynamic content;
@dynamic daily_yn;
@dynamic facebook_yn;
@dynamic twitter_yn;
@dynamic map_yn;
@dynamic image_yn;
@dynamic latitude;
@dynamic longitude;
@dynamic update_count;
@dynamic created_time;
@dynamic updated_time;
@dynamic resources;
@dynamic sectionIdentifier;

- (void)addResourcesObject:(Resource *)value {    
	NSLog(@"call");
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"resources" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"resources"] addObject:value];
    [self didChangeValueForKey:@"resources" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeResourcesObject:(Resource *)value {
	NSLog(@"call");
    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"resources" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"resources"] removeObject:value];
    [self didChangeValueForKey:@"resources" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addResources:(NSSet *)value {    
	NSLog(@"call");
    
    [self willChangeValueForKey:@"resources" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"resources"] unionSet:value];
    [self didChangeValueForKey:@"resources" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeResources:(NSSet *)value {
	NSLog(@"call");
    
    [self willChangeValueForKey:@"resources" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"resources"] minusSet:value];
    [self didChangeValueForKey:@"resources" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

#pragma mark - Transient properties

- (NSString *)sectionIdentifier {
    NSLog(@"call");
    
    [self willAccessValueForKey:@"sectionIdentifier"];
    
    NSString *tmp = [Utils convertDateToString:[Utils convertStringToDate:[self log_time] withFlag:FORMAT_TYPE_FLAG_MIDDLE] withFlag:FORMAT_TYPE_FLAG_READ];
    
    [self didAccessValueForKey:@"sectionIdentifier"];
    
	if (!tmp) {
        [self setSectionIdentifier:tmp];
	}
    
    return tmp;
}

@end
