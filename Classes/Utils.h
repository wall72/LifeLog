//
//  Utils.h
//  LifeLog
//
//  Created by cliff on 11. 3. 7..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Note;
@class Resource;

@interface Utils : NSObject {
    
}

+ (Note *)insertNewNote:(NSString *)insertTime;
+ (Resource *)insertResource:(Note *)newNote;
+ (NSString *)getGenGUID;
+ (NSString *)getTitle:(NSString *)content;
+ (NSString *)getDocumentsDirectory;
+ (void)createDirectory:(NSString *)uuid;
+ (void)deleteDirectory:(NSString *)uuid;
+ (BOOL)isExistFile:(NSString *)uuid withName:(NSString *)fileName;
+ (NSData *)getImageFile:(NSString *)uuid withName:(NSString *)imageName;
+ (void)setImageFile:(NSString *)uuid useData:(NSData *)imageData withName:(NSString *)imageName;
+ (void)setTextFile:(NSString *)uuid useData:(NSString *)textData;
+ (NSData *)retrieveImageFile:(NSString *)uuid useFileId:(NSString *)fileId withName:(NSString *)fileName;
+ (NSNumber *)getFileSize:(NSString *)uuid withName:(NSString *)fileName;
+ (NSString *)convertDateToString:(NSDate *)date withFlag:(NSInteger)flagDay;
+ (NSDate *)convertStringToDate:(NSString *)dateString withFlag:(NSInteger)flagDay;
+ (NSString *)getPoint:(NSInteger)srcValue;
+ (void)showAlert:(NSString *)cancelButtonTitle withTitle:(NSString *)title andMessage:(NSString *)message;
+ (NSString *)base64Encoding:(NSData *)sourceData;

@end
