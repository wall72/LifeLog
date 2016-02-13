//
//  AboutViewController.h
//  LifeLog
//
//  Created by Changho Lee on 11. 6. 22..
//  Copyright 2011 타임교육. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
}

- (IBAction)sendEmail:(id)sender;
- (IBAction)goFacebook:(id)sender;

@end
