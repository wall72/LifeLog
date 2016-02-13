//
//  Utils.m
//  LifeLog
//
//  Created by cliff on 11. 3. 7..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "Utils.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Base64.h"
#import "LifeLogAppDelegate.h"
#import "Note.h"
#import "Resource.h"
#import "Global.h"

@implementation Utils

+ (Note *)insertNewNote:(NSString *)insertTime {
	NSLog(@"call");
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *_managedObjectContext = _appDelegate.managedObjectContext;
    NSManagedObjectModel *_managedObjectModel = _appDelegate.managedObjectModel;
    NSEntityDescription *_entity = [[_managedObjectModel entitiesByName] objectForKey:@"Note"];
    
    Note *_newNote = [[Note alloc] initWithEntity:_entity insertIntoManagedObjectContext:_managedObjectContext];
    
    [_newNote setUuid:[Utils getGenGUID]];
    [_newNote setUser_uuid:[_appDelegate.userInfoBundle objectForKey:@"uuid"]];
    
    NSInteger _day = [[insertTime substringFromIndex:14] intValue];
    
    if (_day < 30) {
        [_newNote setLog_time:[[insertTime substringToIndex:14] stringByAppendingString:@"00"]];
    } else {
        [_newNote setLog_time:[[insertTime substringToIndex:14] stringByAppendingString:@"30"]];
    }
    
    [_newNote setFacebook_yn:[NSNumber numberWithBool:YES]];
    
    int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
    [_newNote setCreated_time:[NSNumber numberWithLongLong:_epoch_time]];
    [_newNote setUpdated_time:[NSNumber numberWithLongLong:_epoch_time]];
    
    [Utils createDirectory:_newNote.uuid];
    
//    NSLog(@"[entity]Note is %@", newNote);

    return [_newNote autorelease];
}

+ (Resource *)insertResource:(Note *)newNote {
	NSLog(@"call");
    
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *_managedObjectContext = _appDelegate.managedObjectContext;
    NSManagedObjectModel *_managedObjectModel = _appDelegate.managedObjectModel;
    NSEntityDescription *_entity = [[_managedObjectModel entitiesByName] objectForKey:@"Resource"];
    
    Resource *_newResource = [[Resource alloc] initWithEntity:_entity insertIntoManagedObjectContext:_managedObjectContext];

    [_newResource setUuid:[Utils getGenGUID]];
    [_newResource setUser_uuid:[_appDelegate.userInfoBundle objectForKey:@"uuid"]];
    [_newResource setNote_uuid:newNote.uuid];
    
    int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
    [_newResource setCreated_time:[NSNumber numberWithLongLong:_epoch_time]];
    [_newResource setUpdated_time:[NSNumber numberWithLongLong:_epoch_time]];
    
    [_newResource setNote:newNote];
    
//    NSLog(@"[entity]Resource is %@", newResource);
    
    return [_newResource autorelease];
}

+ (NSString *)getGenGUID {
	NSLog(@"call");
    
    NSMutableString *_srcStr = [[[NSMutableString alloc] init] autorelease];
    
    // epoch time
    int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
    [_srcStr appendFormat:@"%@:", [NSNumber numberWithLongLong:_epoch_time]];
    
    // UDID
    [_srcStr appendFormat:@"%@:", [[UIDevice currentDevice] uniqueIdentifier]];
    
    // Facebook ID
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    [_srcStr appendFormat:@"%@:", [_appDelegate.facebookBundle objectForKey:@"id"]];
    
    // Random number
    [_srcStr appendFormat:@"%ld", random()];
    
//    NSLog(@"srcStr = %@", _srcStr);
    
    const char *_cStr = [_srcStr UTF8String];
    
    unsigned char _result[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(_cStr, strlen(_cStr), _result);
    
    NSMutableString *_returnString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [_returnString appendFormat:@"%02x", _result[i]];
    }
    
//    NSLog(@"MD5 hash string = %@", [returnString uppercaseString]);

    return [_returnString uppercaseString];
}

+ (NSString *)getTitle:(NSString *)content {
	NSLog(@"call");
    
    NSString *_returnString;

    if (content.length <= 20) {
        _returnString = content;
    } else {
        _returnString = [content substringToIndex:21];
    }
    
    NSRange _range = [_returnString rangeOfString:@"\n"];
    
    if (_range.location != NSNotFound) {
        _returnString = [_returnString substringWithRange:NSMakeRange(0, _range.location)];
    }
    
    if (_returnString.length < content.length) {
        _returnString = [_returnString stringByAppendingString:@"..."];
    }
    
    return _returnString;
}

+ (NSString *)getDocumentsDirectory {
	NSLog(@"call");
	
	NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [_paths objectAtIndex:0];
}

+ (void)createDirectory:(NSString *)uuid {
	NSLog(@"call");
	
	NSFileManager *_fileManager = [NSFileManager defaultManager];
    
	NSString *_path = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", uuid]];
    
    if (![_fileManager fileExistsAtPath:_path]) {
        [_fileManager createDirectoryAtPath:_path withIntermediateDirectories:NO attributes:nil error:NULL];
    }
}

+ (void)deleteDirectory:(NSString *)uuid {
	NSLog(@"call");
	
    NSString *_path = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", uuid]];
    
    [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

+ (BOOL)isExistFile:(NSString *)uuid withName:(NSString *)fileName {
	NSLog(@"call");
	
	NSFileManager *_fileManager = [NSFileManager defaultManager];

	NSString *_file = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", uuid, fileName]];
	
	return [_fileManager fileExistsAtPath:_file];
}

+ (NSData *)getImageFile:(NSString *)uuid withName:(NSString *)imageName {
	NSLog(@"call");
	
	NSString *_imageFile = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", uuid, imageName]];
	
	return [NSData dataWithContentsOfFile:_imageFile];
}

+ (void)setImageFile:(NSString *)uuid useData:(NSData *)imageData withName:(NSString *)imageName {
	NSLog(@"call");
	
	NSString *_imageFile = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", uuid, imageName]];
	
	[imageData writeToFile:_imageFile atomically:NO];
}

+ (void)setTextFile:(NSString *)uuid useData:(NSString *)textData {
	NSLog(@"call");
	
	NSString *_textFile = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/NOTE.TXT", uuid]];
	
	[textData writeToFile:_textFile atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

+ (NSData *)retrieveImageFile:(NSString *)uuid useFileId:(NSString *)fileId withName:(NSString *)fileName {
	NSLog(@"call");
	
    NSString *_fileURLString = [BASE_IMAGE_PATH stringByAppendingString:fileId];
//	NSLog(@"_fileURLString = %@", _fileURLString);
    
    NSURL *_fileURL = [NSURL URLWithString:_fileURLString];
    
    UIApplication *_app = [UIApplication sharedApplication];
    [_app setNetworkActivityIndicatorVisible:YES];

    NSData *_imageData = [NSData dataWithContentsOfURL:_fileURL];
    
    if (_imageData != nil) {
        [Utils setImageFile:uuid useData:_imageData withName:fileName];
    } else {
        [Utils showAlert:NSLocalizedString(@"Confirm", nil) withTitle:NSLocalizedString(@"Error", nil) andMessage:NSLocalizedString(@"ImageLoadFail", nil)];
    }
    
    [_app setNetworkActivityIndicatorVisible:NO];

    return _imageData;
}

+ (NSNumber *)getFileSize:(NSString *)uuid withName:(NSString *)fileName {
	NSLog(@"call");
	
	NSFileManager *_fileManager = [NSFileManager defaultManager];

	NSString *_filePath = [[Utils getDocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", uuid, fileName]];
	
    NSDictionary *_fileAttributes = [_fileManager attributesOfItemAtPath:_filePath error:nil];
    
	return [NSNumber numberWithLongLong:[_fileAttributes fileSize]];
}

+ (NSString *)convertDateToString:(NSDate *)date withFlag:(NSInteger)flagDay {
	NSLog(@"call");
	
	NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];
	
	if (flagDay == FORMAT_TYPE_FLAG_FULL) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	} else if (flagDay == FORMAT_TYPE_FLAG_MIDDLE) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	} else if (flagDay == FORMAT_TYPE_FLAG_SHORT) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd"];
	} else if (flagDay == FORMAT_TYPE_FLAG_READ) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd (ccc)"];
	} else if (flagDay == FORMAT_TYPE_FLAG_READ2) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd (ccc) h:mm a"];
	} else if (flagDay == FORMAT_TYPE_FLAG_SPECIAL) {
		[_dateFormatter setDateFormat:@"HHmm"];
	} else { // FORMAT_TYPE_FLAG_MM
		[_dateFormatter setDateFormat:@"yyyy-MM"];
    }

	NSString *_returnString = [_dateFormatter stringFromDate:date];
	
	[_dateFormatter release];

	return _returnString;
}

+ (NSDate *)convertStringToDate:(NSString *)dateString withFlag:(NSInteger)flagDay {
	NSLog(@"call");
	
	NSDateFormatter *_dateFormatter = [[NSDateFormatter alloc] init];

	if (flagDay == FORMAT_TYPE_FLAG_FULL) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	} else if (flagDay == FORMAT_TYPE_FLAG_MIDDLE) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	} else if (flagDay == FORMAT_TYPE_FLAG_SHORT) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd"];
	} else if (flagDay == FORMAT_TYPE_FLAG_READ) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd (ccc)"];
	} else if (flagDay == FORMAT_TYPE_FLAG_READ2) {
		[_dateFormatter setDateFormat:@"yyyy-MM-dd (ccc) hh:mm a"];
	} else if (flagDay == FORMAT_TYPE_FLAG_SPECIAL) {
		[_dateFormatter setDateFormat:@"HHmm"];
	} else { // FORMAT_TYPE_FLAG_MM
		[_dateFormatter setDateFormat:@"yyyy-MM"];
    }
	
	NSDate *_returnDate = [_dateFormatter dateFromString:dateString];

	[_dateFormatter release];

	return _returnDate;
}

+ (NSString *)getPoint:(NSInteger)srcValue {
	NSLog(@"call");
	
    LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *_settingsSection = [_appDelegate.settingsBundle objectForKey:@"Rating"];
    NSDictionary *_ratingBasis = [_settingsSection objectForKey:@"Rating basis"];

    NSString *_checkedKey = nil;

    NSEnumerator *_enumerator = [_ratingBasis keyEnumerator];
    id _key;
    BOOL _boolFlag;
    while ((_key = [_enumerator nextObject])) {
        _boolFlag = [[_ratingBasis objectForKey:_key] boolValue];
        if (_boolFlag) {
            _checkedKey = _key;
            break;
        }
    }
    
    if ([_checkedKey isEqualToString:@"1,2,3,4,5 Type"]) {
        return [NSString stringWithFormat:@"%d", srcValue];
    } else if ([_checkedKey isEqualToString:@"20,40,60,80,100 Type"]) {
        switch (srcValue) {
            case 1:
                return @"20";
                break;
            case 2:
                return @"40";
                break;
            case 3:
                return @"60";
                break;
            case 4:
                return @"80";
                break;
            case 5:
                return @"100";
                break;
                
            default:
                return @"0";
                break;
        }
    } else { // @"A,B,C,D,F Type"
        switch (srcValue) {
            case 1:
                return @"E";
                break;
            case 2:
                return @"D";
                break;
            case 3:
                return @"C";
                break;
            case 4:
                return @"B";
                break;
            case 5:
                return @"A";
                break;
                
            default:
                return @"F";
                break;
        }
    }
}

+ (void)showAlert:(NSString *)cancelButtonTitle withTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *_alert = [[UIAlertView alloc] initWithTitle:title 
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:cancelButtonTitle
                                           otherButtonTitles:nil, nil];
    [_alert show];
    [_alert release];
}

+ (NSString *)base64Encoding:(NSData *)sourceData {
	NSString *_returnString = [sourceData base64EncodedString];  
//	NSLog(@"Encoded form: %@", _returnString);	
	
	return _returnString;
}

@end
