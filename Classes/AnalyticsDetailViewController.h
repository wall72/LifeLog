//
//  AnalyticsViewController.h
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnalyticsDetailViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIWebViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UISegmentedControl *reportSegment;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *actIndicator;
@property (nonatomic, assign) BOOL analyticsFlag;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIPickerView *monthPicker;

- (IBAction)reportValueChanged:(id)sender;

@end
