//
//  SyncServiceDelegate.m
//  LifeLog
//
//  Created by cliff on 11. 4. 12..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "DataSyncService.h"
#import "LifeLogAppDelegate.h"
#import "Note.h"
#import "Resource.h"
#import "Utils.h"
#import "Global.h"
#import "JSON.h"

@interface DataSyncService ()
- (void)mainSyncProcess:(NSInteger)method;
- (void)authenticate;
- (void)syncNotes;
- (BOOL)isServerNoteDataLatest:(NSDictionary *)serverNote withNote:(Note *)clientNote;
- (NSString *)sendRequest:(NSString *)uri withInfo:(NSString *)info;
- (NSData *)sendRequestImage:(NSString *)uri;
- (NSString *)makeAuthRequestInfo;
- (NSString *)makeSyncLogRequestInfo;
- (NSString *)makeSyncActionRequestInfo:(NSArray *)notes;
- (NSDictionary *)makeDictForRequest:(BOOL)trFlag;
- (NSDictionary *)makeDictForRequest:(BOOL)trFlag withArray:(NSArray *)notes;
- (NSMutableDictionary *)makeSessionInfo;
- (NSInteger)countOfRows;
- (Note *)findNote:(NSString *)uuid;
- (void)findNoteToServer:(NSNumber *)lastSyncTime withArray:(NSMutableArray **)clientToServer;
- (void)makeNoteFromDic:(NSDictionary *)dicNote withResource:(NSArray *)resources;
- (void)applyResourceFromDic:(NSArray *)resources;
- (void)deleteNote:(NSString *)uuid;
- (void)deleteAllNotes;
- (NSFetchedResultsController *)fetchedResultsController;
@end

@implementation DataSyncService

@synthesize syncType = __syncType;
@synthesize progressAlert = _progressAlert;
@synthesize method = __method;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;

- (id)initWithContext:(NSManagedObjectContext *)managedObjectContext withModel:(NSManagedObjectModel *)managedObjectModel {
	NSLog(@"call");
	
    self = [super init];
    
	self.managedObjectContext = managedObjectContext;
    self.managedObjectModel = managedObjectModel;

    return self;
}

- (void)dealloc {
    NSLog(@"call");
    
//    self.progressAlert = nil;
//    self.fetchedResultsController = nil;
//    self.managedObjectContext = nil;
    [_progressAlert release];
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [super dealloc];
}

#pragma mark - Entry Point

- (void)startSyncProcess:(NSInteger)method {
    NSLog(@"call");
    
    [self setMethod:method];
    
    self.progressAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Syncing", nil)
                                                    message:NSLocalizedString(@"PleaseWait", nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *_progressIndicator= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 80, 30, 30)]; 
    _progressIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge; 
    [_progressIndicator startAnimating]; 
    [self.progressAlert addSubview:_progressIndicator]; 
    [_progressIndicator release];
    
    [self.progressAlert show];
//    [self.progressAlert release];
    
    UIApplication *_app = [UIApplication sharedApplication];
    [_app setNetworkActivityIndicatorVisible:YES];
}

- (void)mainSyncProcess:(NSInteger)method {
    NSLog(@"call");
    
    // Start User Sync Process
    
    switch (method) {
        case SYNC_METHOD_FIRST:
            [self authenticate];
            [self syncNotes];
            // Blahh...!!!
            break;
        case SYNC_METHOD_LIST:
            [self syncNotes];
            // Blahh...!!!
            break;
        case SYNC_METHOD_DETAIL:
            // Blahh...!!!
            break;
            
        default:
            break;
    }
    
    [self.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.progressAlert = nil;

    UIApplication *_app = [UIApplication sharedApplication];
    [_app setNetworkActivityIndicatorVisible:NO];
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    [_appDelegate didComplete];
}

#pragma mark - Authenticate

- (void)authenticate {
    NSLog(@"call");
    
    [self.progressAlert setMessage:NSLocalizedString(@"LogIn", nil)];
    
    NSString *_responseInfo = [self sendRequest:AUTH_URI withInfo:[self makeAuthRequestInfo]];
//    NSLog(@"_responseInfo = %@", _responseInfo);
//    NSLog(@"[_responseInfo length] = %d", [_responseInfo length]);
    if ([_responseInfo length] > 0) {
        SBJSON *_jsonParser = [[SBJSON new] autorelease];
        [_jsonParser setHumanReadable:YES];
        
        NSDictionary *_result = [_jsonParser objectWithString:_responseInfo error:nil];    
        
        NSDictionary *_resultDevice = [_jsonParser objectWithString:[_result valueForKey:@"resultDevice"] error:nil];
        NSLog(@"resultDevice = %@", _resultDevice);
        
        NSDictionary *_resultUser = [_jsonParser objectWithString:[_result valueForKey:@"resultUser"] error:nil];
        NSLog(@"resultUser = %@", _resultUser);
        
        LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSURL *_storeURL = [[_appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:@"DeviceInfo.plist"];
        [_resultDevice writeToURL:_storeURL atomically:YES];
        [_appDelegate.deviceInfoBundle release];
        _appDelegate.deviceInfoBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
        
        _storeURL = [[_appDelegate applicationLibraryDirectory] URLByAppendingPathComponent:@"UserInfo.plist"];
        [_resultUser writeToURL:_storeURL atomically:YES];
        [_appDelegate.userInfoBundle release];
        _appDelegate.userInfoBundle = [[NSMutableDictionary alloc] initWithContentsOfURL:_storeURL];
    }
}

#pragma mark - Synchronizing

- (void)syncNotes {
    NSLog(@"call");
    
    [self.progressAlert setMessage:NSLocalizedString(@"CheckSyncLog", nil)];
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    BOOL _allSuccess = NO;
    
    // Send SyncLog and Receive Note & Resource List
    NSString *_syncLogInfo = [self makeSyncLogRequestInfo];
    NSString *_responseInfo = [self sendRequest:SYNCLOG_URI withInfo:_syncLogInfo];
//    NSLog(@"_responseInfo = %@", _responseInfo);
//    NSLog(@"[_responseInfo length] = %d", [_responseInfo length]);
    NSString *syncActionInfo = nil;
    
    if ([_responseInfo length] > 0) {
        SBJSON *_jsonParser = [[SBJSON new] autorelease];
        [_jsonParser setHumanReadable:YES];
        
        // Parse Note & Resource List
        NSDictionary *_result = [_jsonParser objectWithString:_responseInfo error:nil];    
        
        NSArray *_resultListNote = [_jsonParser objectWithString:[_result valueForKey:@"resultListNote"] error:nil];
        NSLog(@"_resultListNote = %@", _resultListNote);
        
        NSArray *_resultListResource = [_jsonParser objectWithString:[_result valueForKey:@"resultListResource"] error:nil];
        NSLog(@"_resultListResource = %@", _resultListResource);
        
        // Determine Full Sync
        NSLog(@"self.syncType = %d", self.syncType);
        
        if (self.syncType == SYNC_TYPE_FULL) {
            [self.progressAlert setMessage:NSLocalizedString(@"StartFullSync", nil)];
            
            // Delete All Notes
            [self deleteAllNotes];
            
            // Insert Notes (Server -> Client)
            for (int i = 0; i < [_resultListNote count]; i++) {
                NSDictionary *_tmpDicNote = [_resultListNote objectAtIndex:i];
                [self makeNoteFromDic:_tmpDicNote withResource:_resultListResource];
            }
            
            // Received Result
            syncActionInfo = [self makeSyncActionRequestInfo:[NSDictionary dictionary]];
            
            _allSuccess = YES;
        } else {
            [self.progressAlert setMessage:NSLocalizedString(@"StartIncreSync", nil)];
            
            // Validate Update Notes
            NSMutableArray *_serverToClient = [[[NSMutableArray alloc] init] autorelease];
            NSMutableArray *_clientToServer = [[[NSMutableArray alloc] init] autorelease];
            for (int i = 0; i < [_resultListNote count]; i++) {
                NSDictionary *_tmpDicNote = [_resultListNote objectAtIndex:i];
                
                Note *_tmpNote = [self findNote:[_tmpDicNote objectForKey:@"uuid"]];
                
                // 서버가 반영대상이면 
                if ([self isServerNoteDataLatest:_tmpDicNote withNote:_tmpNote]) {
                    // Dictionary 보관
                    [_serverToClient addObject:_tmpDicNote];
                } else {
                    // client Data Dictionary 추가
                    [_clientToServer addObject:_tmpNote];
                }
            }

            // 클라이언트에서 lst 이후의 데이터를 읽어서 보관한다.
            NSNumber *_tmpLastSyncTime = [_appDelegate.syncLogInfoBundle objectForKey:@"zb_note"];
            [self findNoteToServer:_tmpLastSyncTime withArray:&_clientToServer];
            
            // Save Server -> Client
            NSLog(@"_serverToClient = %@", _serverToClient);
            for (int i = 0; i < [_serverToClient count]; i++) {
                NSDictionary *_tmpDicNote = [_serverToClient objectAtIndex:i];
                // Delete Note
                [self deleteNote:[_tmpDicNote objectForKey:@"uuid"]];
                // Insert Note
                [self makeNoteFromDic:_tmpDicNote withResource:_resultListResource];
            }
            
            NSLog(@"_clientToServer = %@", _clientToServer);

            // Received Result
            syncActionInfo = [self makeSyncActionRequestInfo:_clientToServer];
            
            _allSuccess = YES;
        }
        
        // Send client data to server
        if (_allSuccess == YES) {
            // Send client data
            [self.progressAlert setMessage:NSLocalizedString(@"SendClientData", nil)];
            _responseInfo = [self sendRequest:SYNCACTION_URI withInfo:syncActionInfo];
            NSLog(@"_responseInfo = %@", _responseInfo);
            NSLog(@"[_responseInfo length] = %d", [_responseInfo length]);
            
            if ([_responseInfo length] > 0) {
                _result = [_jsonParser objectWithString:_responseInfo error:nil];    
                
                NSArray *_resultSynclog = [_jsonParser objectWithString:[_result valueForKey:@"resultSynclog"] error:nil];
                NSLog(@"_resultSynclog = %@", _resultSynclog);
                
                _resultListResource = [_jsonParser objectWithString:[_result valueForKey:@"resultResource"] error:nil];
                NSLog(@"_resultListResource = %@", _resultListResource);
                
                // Update resource
                [self applyResourceFromDic:_resultListResource];
                
                // Save SyncLog
                if (_appDelegate.syncLogInfoBundle == nil) {
                    NSLog(@"********************************************************");
                    _appDelegate.syncLogInfoBundle = [NSMutableDictionary dictionary];
                    int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
                    [_appDelegate.syncLogInfoBundle setObject:[NSNumber numberWithLongLong:_epoch_time] forKey:@"zb_note"];
                }
                
                for (int i = 0; i < [_resultSynclog count]; i++) {
                    NSDictionary *_tmpDicSyncLog = [_resultSynclog objectAtIndex:i];
                    [_appDelegate.syncLogInfoBundle setObject:[_tmpDicSyncLog objectForKey:@"last_sync_time"] forKey:[_tmpDicSyncLog objectForKey:@"table_id"]];
                }
                [_appDelegate saveSyncLogs];
            }
        }
        
        // Save the context.
        [_appDelegate saveContext];
    }
}

- (BOOL)isServerNoteDataLatest:(NSDictionary *)serverNote withNote:(Note *)clientNote {
    NSLog(@"call");
    
    if ([[serverNote objectForKey:@"update_count"] intValue] < [clientNote.update_count intValue] && [[serverNote objectForKey:@"updated_time"] longLongValue] < [clientNote.updated_time longLongValue]) {
        NSLog(@"Client Data is latest data...");
        return NO;
    } else {
        NSLog(@"Server Data is latest data...");
        return YES;
    }
}

#pragma mark - Server Request and Response

- (NSString *)sendRequest:(NSString *)uri withInfo:(NSString *)info {
    NSLog(@"call");
    
    NSString *_urlString = [BASE_URL stringByAppendingString:uri];
    
    NSMutableURLRequest *_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:REGISTRATION_TIMEOUT_MS]; 
    [_request setHTTPMethod:@"POST"];
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSData* _requestData = [info dataUsingEncoding:NSUTF8StringEncoding];
    [_request setHTTPBody:_requestData];
    
    NSHTTPURLResponse *_response = nil;
	NSError *_error = nil; 
	NSData *_responseData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&_response error:&_error]; 
    
    if (_response == nil) {
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"UnableServer", nil)];
    }
    
    NSInteger _statusCode = [_response statusCode];
    NSLog(@"_statusCode = %d", _statusCode);
    NSString *_contentType = [[_response allHeaderFields] objectForKey:@"Content-Type"];
    NSLog(@"_contentType = %@", _contentType);
    
	if (_statusCode >= 200 && _statusCode < 300) {
        return [[[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding] autorelease];
    } else {
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:[NSString stringWithFormat:NSLocalizedString(@"ServerError", nil), _statusCode]];
        return @"";
    }
}

- (NSData *)sendRequestImage:(NSString *)fileId {
    NSLog(@"call");
    
    NSString *_urlString = [BASE_IMAGE_PATH stringByAppendingString:fileId];
    
    NSURL *_url = [[NSURL alloc] initWithString:_urlString];
    NSURLRequest *_request = [[NSURLRequest alloc] initWithURL:_url];
    
    NSHTTPURLResponse *_response = nil;
	NSError *_error = nil; 
	NSData *_responseData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&_response error:&_error]; 
    
    if (_response == nil) {
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"UnableServer", nil)];
    }
    
    NSInteger _statusCode = [_response statusCode];
    NSLog(@"_statusCode = %d", _statusCode);
    NSString *_contentType = [[_response allHeaderFields] objectForKey:@"Content-Type"];
    NSLog(@"_contentType = %@", _contentType);
    
    [_request release];
    [_url release];
    
	if (_statusCode >= 200 && _statusCode < 300) {
        return _responseData;
    } else {
//        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:[NSString stringWithFormat:NSLocalizedString(@"ServerError", nil), _statusCode]];
        return nil;
    }
}

- (NSString *)makeAuthRequestInfo {
    NSLog(@"call");
    
    SBJSON *_json = [SBJSON new];
    [_json setHumanReadable:YES];
    
	NSError *_error = nil; 
    NSString *_jsonData = [_json stringWithObject:[self makeDictForRequest:REQUEST_TYPE_AUTHENTICATE] error:&_error];
    NSLog(@"_error = %@", _error);
    NSLog(@"converted data = %@", _jsonData);
    
    [_json release];
    
    return _jsonData;
}

- (NSString *)makeSyncLogRequestInfo {
    NSLog(@"call");
    
    SBJSON *_json = [SBJSON new];
    [_json setHumanReadable:YES];
    
	NSError *_error = nil; 
    NSString *_jsonData = [_json stringWithObject:[self makeDictForRequest:REQUEST_TYPE_SYNCLOG] error:&_error];
    NSLog(@"_error = %@", _error);
    NSLog(@"converted data = %@", _jsonData);
    
    [_json release];
    
    return _jsonData;
}

- (NSString *)makeSyncActionRequestInfo:(NSArray *)notes {
    NSLog(@"call");
    
    SBJSON *_json = [SBJSON new];
    [_json setHumanReadable:YES];
    
	NSError *_error = nil; 
    NSString *_jsonData = [_json stringWithObject:[self makeDictForRequest:REQUEST_TYPE_SYNCACTION withArray:notes] error:&_error];
    NSLog(@"_error = %@", _error);
    NSLog(@"converted data = %@", _jsonData);
    
    [_json release];
    
    return _jsonData;
}

- (NSDictionary *)makeDictForRequest:(BOOL)trFlag {
	NSLog(@"call");
	
    NSMutableDictionary *_requestDict = [NSMutableDictionary dictionary];
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (trFlag == REQUEST_TYPE_AUTHENTICATE) {
        NSMutableDictionary *_deviceDict = [NSMutableDictionary dictionary];
        [_deviceDict setValue:@"" forKey:@"uuid"];
        [_deviceDict setValue:@"" forKey:@"userUuid"];
        [_deviceDict setValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"deviceId"];
        [_deviceDict setValue:@"iOS" forKey:@"osType"];
        [_deviceDict setValue:[_appDelegate.facebookBundle valueForKey:@"accessToken"] forKey:@"accessToken"];
        [_deviceDict setValue:[NSNumber numberWithLongLong:([[_appDelegate.facebookBundle valueForKey:@"expirationDate"] timeIntervalSince1970] * 1000)] forKey:@"accessExpires"];
        [_requestDict setValue:_deviceDict forKey:@"objDevice"];
        
        NSMutableDictionary *_userDict = [NSMutableDictionary dictionary];
        [_userDict setValue:@"" forKey:@"uuid"];
        [_userDict setValue:[_appDelegate.facebookBundle valueForKey:@"email"] forKey:@"email"];
        [_userDict setValue:[_appDelegate.facebookBundle valueForKey:@"first_name"] forKey:@"firstName"];
        [_userDict setValue:[_appDelegate.facebookBundle valueForKey:@"last_name"] forKey:@"lastName"];
        [_userDict setValue:[NSNumber numberWithInt:1] forKey:@"active"];
        [_userDict setValue:[_appDelegate.facebookBundle valueForKey:@"locale"] forKey:@"language"];
        //[_userDict setValue:[appDelegate.facebookBundle valueForKey:@"timeZone"] forKey:@"time_zone"];
        [_userDict setValue:[NSNumber numberWithInt:1] forKey:@"ratingBasis"]; // 향후 수정 요망
        [_userDict setValue:[_appDelegate.facebookBundle valueForKey:@"id"] forKey:@"facebookUid"];
        [_userDict setValue:[_appDelegate.facebookBundle valueForKey:@"gender"] forKey:@"gender"];
        //[_userDict setValue:@"" forKey:@"job_type"]; // 향후 수정 요망
        [_requestDict setValue:_userDict forKey:@"objUser"];

        return _requestDict;
    } else { // REQUEST_TYPE_SYNCLOG
        // Session info
        _requestDict = [self makeSessionInfo];
        
        return _requestDict;
    }
}

- (NSDictionary *)makeDictForRequest:(BOOL)trFlag withArray:(NSArray *)notes {
	NSLog(@"call");
	
    NSMutableDictionary *_requestDict = [NSMutableDictionary dictionary];
    
    if (trFlag == REQUEST_TYPE_SYNCACTION) {
        // Session info
        _requestDict = [self makeSessionInfo];
        
        // Notes & Resources info
        NSMutableArray *_tmpArrayNotes = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray *_tmpArrayResources = [[[NSMutableArray alloc] init] autorelease];
        for (int i = 0; i < [notes count]; i++) {
            Note *_tmpNote = [notes objectAtIndex:i];
            
            NSMutableDictionary *_tmpDicNote = [NSMutableDictionary dictionary];
            [_tmpDicNote setValue:_tmpNote.uuid forKey:@"uuid"];
            [_tmpDicNote setValue:_tmpNote.user_uuid forKey:@"userUuid"];
            [_tmpDicNote setValue:_tmpNote.title forKey:@"title"];
            [_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.active intValue]] forKey:@"active"];
            [_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.published intValue]] forKey:@"published"];
            [_tmpDicNote setValue:_tmpNote.feeling forKey:@"feeling"];
            [_tmpDicNote setValue:_tmpNote.rating_score forKey:@"ratingScore"];
            [_tmpDicNote setValue:_tmpNote.log_time forKey:@"logTime"];
            [_tmpDicNote setValue:_tmpNote.content forKey:@"content"];
            //[_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.daily_yn intValue]] forKey:@"dailyYn"];
            //[_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.facebook_yn intValue]] forKey:@"facebookYn"];
            //[_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.twitter_yn intValue]] forKey:@"twitterYn"];
            [_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.map_yn intValue]] forKey:@"mapYn"];
            [_tmpDicNote setValue:[NSString stringWithFormat:@"%d", [_tmpNote.image_yn intValue]] forKey:@"imageYn"];
            [_tmpDicNote setValue:_tmpNote.latitude forKey:@"latitude"];
            [_tmpDicNote setValue:_tmpNote.longitude forKey:@"longitude"];
            [_tmpDicNote setValue:_tmpNote.update_count forKey:@"updateCount"];
            [_tmpDicNote setValue:_tmpNote.created_time forKey:@"createdTime"];
            [_tmpDicNote setValue:_tmpNote.updated_time forKey:@"updatedTime"];
            
            [_tmpArrayNotes addObject:_tmpDicNote];
            
            if ([_tmpNote.active boolValue]) {
                // Get Resources
                NSSet *_rowSet = [_tmpNote valueForKey:@"resources"];
                
                NSEnumerator *_enumerator = [_rowSet objectEnumerator];
                Resource *_tmpResource;
                while ((_tmpResource = [_enumerator nextObject])) {
                    NSInteger _type = [_tmpResource.type intValue];
                    if(_type == 2) {
                        NSMutableDictionary *_tmpDicResource = [NSMutableDictionary dictionary];
                        [_tmpDicResource setValue:_tmpResource.uuid forKey:@"uuid"];
                        [_tmpDicResource setValue:_tmpResource.user_uuid forKey:@"userUuid"];
                        [_tmpDicResource setValue:_tmpResource.note_uuid forKey:@"noteUuid"];
                        [_tmpDicResource setValue:_tmpResource.mime forKey:@"mime"];
                        [_tmpDicResource setValue:_tmpResource.file_name forKey:@"fileName"];
                        [_tmpDicResource setValue:_tmpResource.file_id!=nil?_tmpResource.file_id:@"" forKey:@"fileId"];
                        //[_tmpDicResource setValue:@"/Documents" forKey:@"path"];
                        [_tmpDicResource setValue:_tmpResource.file_size forKey:@"fileSize"];
                        [_tmpDicResource setValue:_tmpResource.display_sequence forKey:@"displaySequence"];
                        [_tmpDicResource setValue:[NSString stringWithFormat:@"%d", [_tmpResource.active intValue]] forKey:@"active"];
                        [_tmpDicResource setValue:_tmpResource.type forKey:@"type"];
                        [_tmpDicResource setValue:_tmpResource.update_count forKey:@"updateCount"];
                        [_tmpDicResource setValue:_tmpResource.created_time forKey:@"createdTime"];
                        [_tmpDicResource setValue:_tmpResource.updated_time forKey:@"updatedTime"];
                        
                        // Image 를 base64 인코딩해서 첨부
                        NSData *_fileContentsData = nil;
                        if ([_tmpNote.image_yn boolValue]) {
                            if ([Utils isExistFile:_tmpNote.uuid withName:_tmpResource.file_name]) {
                                _fileContentsData = [Utils getImageFile:_tmpNote.uuid withName:_tmpResource.file_name];
                            }
                        }
                        
                        NSString *_fileContents = @"";
                        if (_fileContentsData != nil) {
                            _fileContents = [Utils base64Encoding:_fileContentsData];
                        }
                        
                        [_tmpDicResource setValue:_fileContents forKey:@"fileContents"];
                        
                        [_tmpArrayResources addObject:_tmpDicResource];
                    }
                }
            }
        }
        
        [_requestDict setValue:@"SUCCESS" forKey:@"objNoteSyncResult"];
        [_requestDict setValue:@"SUCCESS" forKey:@"objResSyncResult"];
        [_requestDict setValue:_tmpArrayNotes forKey:@"objNoteSyncResultToServerData"];
        [_requestDict setValue:_tmpArrayResources forKey:@"objResSyncResultToServerData"];
    }
    
    NSLog(@"_requestDict = %@", _requestDict);
    
    return _requestDict;
}

- (NSMutableDictionary *)makeSessionInfo {
	NSLog(@"call");
	
    NSMutableDictionary *_requestDict = [NSMutableDictionary dictionary];
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Device info
    NSMutableDictionary *_deviceDict = [NSMutableDictionary dictionary];
    [_deviceDict setValue:[_appDelegate.deviceInfoBundle valueForKey:@"uuid"] forKey:@"uuid"];
    [_deviceDict setValue:[_appDelegate.deviceInfoBundle valueForKey:@"user_uuid"] forKey:@"userUuid"];
    [_deviceDict setValue:[_appDelegate.deviceInfoBundle valueForKey:@"device_id"] forKey:@"deviceId"];
    [_deviceDict setValue:[_appDelegate.deviceInfoBundle valueForKey:@"os_type"] forKey:@"osType"];
    [_deviceDict setValue:[_appDelegate.deviceInfoBundle valueForKey:@"accesstoken"] forKey:@"accessToken"];
    [_deviceDict setValue:[_appDelegate.deviceInfoBundle valueForKey:@"access_expires"] forKey:@"accessExpires"];
    [_requestDict setValue:_deviceDict forKey:@"objDevice"];
    
    // User info
    NSMutableDictionary *_userDict = [NSMutableDictionary dictionary];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"uuid"] forKey:@"uuid"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"email"] forKey:@"email"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"first_name"] forKey:@"firstName"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"last_name"] forKey:@"lastName"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"active"] forKey:@"active"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"language"] forKey:@"language"];
    //[_userDict setValue:[appDelegate.userInfoBundle valueForKey:@"time_zone"] forKey:@"timeZone"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"rating_basis"] forKey:@"ratingBasis"]; // 향후 수정 요망
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"facebook_uid"] forKey:@"facebookUid"];
    [_userDict setValue:[_appDelegate.userInfoBundle valueForKey:@"gender"] forKey:@"gender"];
    //[_userDict setValue:[appDelegate.userInfoBundle valueForKey:@"job_type"] forKey:@"job_type"]; // 향후 수정 요망
    [_requestDict setValue:_userDict forKey:@"objUser"];
    
    // Synclog info
    NSMutableArray *_syncLogDicts = [[[NSMutableArray alloc] init] autorelease];
    NSLog(@"_appDelegate.syncLogInfoBundle = %@", _appDelegate.syncLogInfoBundle);
    if (_appDelegate.syncLogInfoBundle == nil) {
        [self setSyncType:SYNC_TYPE_FULL];
    } else {
        for (NSString *_key in _appDelegate.syncLogInfoBundle) {
            if ([[_appDelegate.syncLogInfoBundle objectForKey:_key] intValue] == 0) {
                [self setSyncType:SYNC_TYPE_FULL];
                break;
            }
            
            NSMutableDictionary *_syncLogDict = [NSMutableDictionary dictionary];
            [_syncLogDict setValue:@"" forKey:@"uuid"];
            [_syncLogDict setValue:[_appDelegate.userInfoBundle valueForKey:@"uuid"] forKey:@"userUuid"];
            [_syncLogDict setValue:[[UIDevice currentDevice] uniqueIdentifier] forKey:@"deviceId"];
            [_syncLogDict setValue:_key forKey:@"tableId"];
            [_syncLogDict setValue:[_appDelegate.syncLogInfoBundle objectForKey:_key] forKey:@"lastSyncTime"];
            [_syncLogDicts addObject:_syncLogDict];
            
        }
    }
    [_requestDict setValue:_syncLogDicts forKey:@"objSynclog"];

    return _requestDict;
}

#pragma mark - DB job

- (NSInteger)countOfRows {
	NSLog(@"call");
	
    id <NSFetchedResultsSectionInfo> _sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [_sectionInfo numberOfObjects];
}

- (Note *)findNote:(NSString *)uuid {
	NSLog(@"call");
	
    Note *_note = nil;
    NSArray *_fetchedObjects = [self.fetchedResultsController fetchedObjects];
    for (int i = 0; i < [_fetchedObjects count]; i++) {
        _note = [_fetchedObjects objectAtIndex:i];
        if ([uuid isEqualToString:_note.uuid]) {
            break;
        }
    }
    return _note;
}

- (void)findNoteToServer:(NSNumber *)lastSyncTime withArray:(NSMutableArray **)clientToServer {
	NSLog(@"call");
    NSLog(@"lastSyncTime = %@", lastSyncTime);
	
    NSArray *_fetchedObjects = [self.fetchedResultsController fetchedObjects];
    for (int i = 0; i < [_fetchedObjects count]; i++) {
        Note *_note = [_fetchedObjects objectAtIndex:i];
        NSLog(@"note.updated_time = %@", _note.updated_time);
        if ([_note.updated_time compare:lastSyncTime] == NSOrderedDescending || [_note.updated_time compare:lastSyncTime] == NSOrderedSame) {
            if (![*clientToServer containsObject:_note]) {
                [*clientToServer addObject:_note];
            }
        }
    }
}

- (void)makeNoteFromDic:(NSDictionary *)dicNote withResource:(NSArray *)resources {
	NSLog(@"call");
	
    NSEntityDescription *_entity = [[self.managedObjectModel entitiesByName] objectForKey:@"Note"];
    
    Note *_newNote = [[[Note alloc] initWithEntity:_entity insertIntoManagedObjectContext:self.managedObjectContext] autorelease];

    [_newNote setUuid:[dicNote objectForKey:@"uuid"]];
    [_newNote setUser_uuid:[dicNote objectForKey:@"user_uuid"]];
    [_newNote setTitle:[dicNote objectForKey:@"title"]];
    [_newNote setActive:[NSNumber numberWithBool:[[dicNote objectForKey:@"active"] boolValue]]];
    [_newNote setPublished:[NSNumber numberWithBool:[[dicNote objectForKey:@"published"] boolValue]]];
    [_newNote setFeeling:[dicNote objectForKey:@"feeling"]];
    [_newNote setRating_score:[NSNumber numberWithInt:[[dicNote objectForKey:@"rating_score"] intValue]]];
    [_newNote setLog_time:[dicNote objectForKey:@"log_time"]];
    [_newNote setContent:[dicNote objectForKey:@"content"]];
    //[_newNote setDaily_yn:[NSNumber numberWithBool:[[dicNote objectForKey:@"daily_yn"] boolValue]]];
    [_newNote setDaily_yn:[NSNumber numberWithBool:NO]];
    //[_newNote setFacebook_yn:[NSNumber numberWithBool:[[dicNote objectForKey:@"facebook_yn"] boolValue]]];
    [_newNote setFacebook_yn:[NSNumber numberWithBool:[[dicNote objectForKey:@"published"] boolValue]]];
    //[_newNote setTwitter_yn:[NSNumber numberWithBool:[[dicNote objectForKey:@"twitter_yn"] boolValue]]];
    [_newNote setTwitter_yn:[NSNumber numberWithBool:NO]];
    [_newNote setMap_yn:[NSNumber numberWithBool:[[dicNote objectForKey:@"map_yn"] boolValue]]];
    [_newNote setImage_yn:[NSNumber numberWithBool:[[dicNote objectForKey:@"image_yn"] boolValue]]]; // [NSNumber numberWithBool:NO];
    [_newNote setLatitude:[NSNumber numberWithFloat:[[dicNote objectForKey:@"latitude"] floatValue]]];
    [_newNote setLongitude:[NSNumber numberWithFloat:[[dicNote objectForKey:@"longitude"] floatValue]]];
    [_newNote setUpdate_count:[NSNumber numberWithInt:[[dicNote objectForKey:@"update_count"] intValue]]];
    [_newNote setCreated_time:[NSNumber numberWithLongLong:[[dicNote objectForKey:@"created_time"] longLongValue]]];
    [_newNote setUpdated_time:[NSNumber numberWithLongLong:[[dicNote objectForKey:@"updated_time"] longLongValue]]];
    
    NSLog(@"[entity]Note is %@", _newNote);

    [Utils createDirectory:_newNote.uuid];
    
    [Utils setTextFile:_newNote.uuid useData:_newNote.content];
    
    NSDictionary *_tmpDicResource = nil;
    
    for (int j = 0; j < [resources count]; j++) {
        _tmpDicResource = [resources objectAtIndex:j];
        if ([_newNote.uuid isEqualToString:[_tmpDicResource objectForKey:@"note_uuid"]]) {
            break;
        }
    }
    
    if (_tmpDicResource != nil) {
        NSEntityDescription *_entity2 = [[self.managedObjectModel entitiesByName] objectForKey:@"Resource"];
        
        Resource *_newResource = [[[Resource alloc] initWithEntity:_entity2 insertIntoManagedObjectContext:self.managedObjectContext] autorelease];
    
        [_newResource setNote:_newNote];
        
        [_newResource setUuid:[_tmpDicResource objectForKey:@"uuid"]];
        [_newResource setUser_uuid:[_tmpDicResource objectForKey:@"user_uuid"]];
        [_newResource setNote_uuid:[_tmpDicResource objectForKey:@"note_uuid"]];
        [_newResource setMime:[_tmpDicResource objectForKey:@"mime"]];
        [_newResource setFile_name:[_tmpDicResource objectForKey:@"file_name"]];
        
        NSDictionary *_tmpDicFileID = [_tmpDicResource objectForKey:@"file_id"];
        [_newResource setFile_id:[_tmpDicFileID objectForKey:@"blobKey"]];
        
        [_newResource setPath:@"/Documents"];
        [_newResource setFile_size:[NSNumber numberWithInt:[[_tmpDicResource objectForKey:@"file_size"] intValue]]];
        [_newResource setDisplay_sequence:[NSNumber numberWithInt:[[_tmpDicResource objectForKey:@"display_sequence"] intValue]]];
        [_newResource setActive:[NSNumber numberWithBool:[[_tmpDicResource objectForKey:@"active"] boolValue]]];
        [_newResource setType:[_tmpDicResource objectForKey:@"type"]];
        [_newResource setUpdate_count:[NSNumber numberWithInt:[[_tmpDicResource objectForKey:@"update_count"] intValue]]];
        [_newResource setCreated_time:[NSNumber numberWithLongLong:[[_tmpDicResource objectForKey:@"created_time"] longLongValue]]];
        [_newResource setUpdated_time:[NSNumber numberWithLongLong:[[_tmpDicResource objectForKey:@"updated_time"] longLongValue]]];
        
        // download image data
        if ([_newNote.image_yn boolValue]) {
            NSData *_imageData = [self sendRequestImage:_newResource.file_id];
            if (_imageData != nil) {
                [Utils setImageFile:_newNote.uuid useData:_imageData withName:_newResource.file_name];
            //} else {
                //[_newNote setImage_yn:[NSNumber numberWithBool:NO]];
            }
        }

        NSLog(@"[entity]Resource is %@", _newResource);
    }
}

- (void)applyResourceFromDic:(NSArray *)resources {
	NSLog(@"call");
	
    NSArray *_fetchedObjects = [self.fetchedResultsController fetchedObjects];
	
    for (int i = 0; i < [_fetchedObjects count]; i++) {
        Note *_note = [_fetchedObjects objectAtIndex:i];
        
        NSDictionary *_tmpDicResource = nil;
        
        for (int j = 0; j < [resources count]; j++) {
            _tmpDicResource = [resources objectAtIndex:j];
            if ([_note.uuid isEqualToString:[_tmpDicResource objectForKey:@"note_uuid"]]) {
                break;
            }
        }

        if (_tmpDicResource != nil) {
            NSSet *_rowSet = [_note valueForKey:@"resources"];
            
            NSEnumerator *_enumerator = [_rowSet objectEnumerator];
            Resource *_camResource;
            
            while ((_camResource = [_enumerator nextObject])) {
                NSInteger _type = [_camResource.type intValue];
                if(_type == 2) {
                    break;
                }
            }
    
            NSDictionary *_tmpDicFileID = [_tmpDicResource objectForKey:@"file_id"];
            [_camResource setFile_id:[_tmpDicFileID objectForKey:@"blobKey"]];
            
            NSLog(@"[entity]Resource is %@", _camResource);
        }
    }
}

- (void)deleteNote:(NSString *)uuid {
	NSLog(@"call");
    
    NSArray *_fetchedObjects = [self.fetchedResultsController fetchedObjects];
	
    for (int i = 0; i < [_fetchedObjects count]; i++) {
        Note *_note = [_fetchedObjects objectAtIndex:i];
        
        if ([_note.uuid isEqualToString:uuid]) {
            [Utils deleteDirectory:_note.uuid];
            
            [self.managedObjectContext deleteObject:_note];
        }
    }
}

- (void)deleteAllNotes {
	NSLog(@"call");
    
    NSArray *_fetchedObjects = [self.fetchedResultsController fetchedObjects];
	
    for (int i = 0; i < [_fetchedObjects count]; i++) {
        Note *_note = [_fetchedObjects objectAtIndex:i];
        
        [Utils deleteDirectory:_note.uuid];
		
        [self.managedObjectContext deleteObject:_note];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
	NSLog(@"call");
	
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    // Create the fetch request for the entity.
    NSFetchRequest *_fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *_entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
    [_fetchRequest setEntity:_entity];
    
    // Set the batch size to a suitable number.
    [_fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *_sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"log_time" ascending:NO];
    NSArray *_sortDescriptors = [[NSArray alloc] initWithObjects:_sortDescriptor, nil];
    
    [_fetchRequest setSortDescriptors:_sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *_aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_fetchRequest 
																								managedObjectContext:self.managedObjectContext 
																								  sectionNameKeyPath:nil
																										   cacheName:nil];
    _aFetchedResultsController.delegate = nil;
    self.fetchedResultsController = _aFetchedResultsController;
    
    [_aFetchedResultsController release];
    [_fetchRequest release];
    [_sortDescriptor release];
    [_sortDescriptors release];
    
    NSError *_error = nil;
    if (![self.fetchedResultsController performFetch:&_error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. 
		 You should not use this function in a shipping application, although it may be useful during development. 
		 If it is not possible to recover from the error, display an alert panel that instructs the user to quit 
		 the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", _error, [_error userInfo]);
        abort();
    }
    
    return __fetchedResultsController;
}

#pragma mark - UIAlertView delegate

- (void)didPresentAlertView:(UIAlertView *)alertView {
    NSLog(@"call");
    
    [self setSyncType:SYNC_TYPE_INC];
    
    [self mainSyncProcess:self.method];
}

@end
