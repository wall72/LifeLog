//
//  Global.h
//  LifeLog
//
//  Created by cliff on 11. 3. 17..
//  Copyright 2011 teamzepa. All rights reserved.
//

// Facebook app id
#define FACEBOOK_APP_ID             @"212708402099293"

// AdMob publisher id
#define ADMOB_PUBLISHER_ID          @"a14d899b0765403"

// Cauly publisher id
#define CAULY_PUBLISHER_ID          @"CAULY"

// NAV_CONTROL for DailyListViewController
#define NAV_PREVDAY                 1
#define NAV_NEXTDAY                 2

// Sync server constants
#define REGISTRATION_TIMEOUT_MS     30 * 1000 // ms
#define SERVER_PORT                 80
#define BASE_URL                    @"http://imtzepalifelog.appspot.com/"
#define AUTH_URI                    @"SyncServlet"
#define SYNCLOG_URI                 @"SyncServlet02"
#define SYNCACTION_URI              @"SyncServlet03"
#define BASE_IMAGE_PATH             @"http://imtzepalifelog.appspot.com/ResourceServlet?cmd=URL&key="
#define ANALYTICS_OUTCOME_PATH1     @"http://imtzepalifelog.appspot.com/mobile/tab01.jsp"
#define ANALYTICS_OUTCOME_PATH2     @"http://imtzepalifelog.appspot.com/mobile/tab03.jsp"
#define ANALYTICS_OUTCOME_PATH3     @"http://imtzepalifelog.appspot.com/mobile/tab02.jsp"
#define ANALYTICS_FEELING_PATH1     @"http://imtzepalifelog.appspot.com/mobile/tab04.jsp"
#define ANALYTICS_FEELING_PATH2     @"http://imtzepalifelog.appspot.com/mobile/tab06.jsp"
#define ANALYTICS_FEELING_PATH3     @"http://imtzepalifelog.appspot.com/mobile/tab05.jsp"
#define FACEBOOK_PAGE_PATH          @"http://touch.facebook.com/pages/LifeLog/161660957234288"
#define ADMIN_EMAIL                 @"imtsystemkr@gmail.com"

// NKDateComponents
#define ONEDAY_SECOND				(24 * 60 * 60)

// NSDateFormatter flag
#define FORMAT_TYPE_FLAG_FULL		0
#define FORMAT_TYPE_FLAG_MIDDLE		1
#define FORMAT_TYPE_FLAG_SHORT		2
#define FORMAT_TYPE_FLAG_READ		3
#define FORMAT_TYPE_FLAG_READ2		4
#define FORMAT_TYPE_FLAG_SPECIAL    5
#define FORMAT_TYPE_FLAG_MM         6

// Add/Detail View flag
#define TR_TYPE_INSERT              1
#define TR_TYPE_EDIT                0
#define TR_TYPE_READ                -1

// RGB MACRO
#define RGB(r, g, b)                [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

// Daily View Time Span
#define SIZE_OF_TIME_SPAN           18

// MD5 Digest Length
#define CC_MD5_DIGEST_LENGTH        16

// Server Sync Type
#define SYNC_TYPE_FULL              0
#define SYNC_TYPE_INC               1

// Server Sync Method
#define SYNC_METHOD_FIRST           0
#define SYNC_METHOD_LIST            1
#define SYNC_METHOD_DETAIL          2

// Server Sync Request Type
#define REQUEST_TYPE_AUTHENTICATE   0
#define REQUEST_TYPE_SYNCLOG        1
#define REQUEST_TYPE_SYNCACTION     2
