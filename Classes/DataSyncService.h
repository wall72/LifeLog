//
//  SyncServiceDelegate.h
//  LifeLog
//
//  Created by cliff on 11. 4. 12..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSyncService : NSObject <UIAlertViewDelegate> {

}

@property (nonatomic, assign) NSInteger syncType;
@property (nonatomic, retain) UIAlertView *progressAlert;
@property (nonatomic, assign) NSInteger method;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext withModel:(NSManagedObjectModel *)managedObjectModel;
- (void)startSyncProcess:(NSInteger)method;

@end
