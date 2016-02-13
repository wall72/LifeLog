//
//  AddViewController.h
//  LifeLog
//
//  Created by cliff on 11. 3. 7..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DLStarRatingControl.h"
#import "FBConnect.h"

@class Note;

@interface AddViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, DLStarRatingDelegate>{

}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UILabel *pointLabel;
@property (nonatomic, retain) IBOutlet UITextView *contentTextView;
@property (nonatomic, retain) IBOutlet UIButton *feelingButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UIButton *imageButton;
@property (nonatomic, retain) IBOutlet UIButton *mapButton;
@property (nonatomic, retain) IBOutlet UILabel *latitudeLabel;
@property (nonatomic, retain) IBOutlet UILabel *longitudeLabel;
@property (nonatomic, retain) IBOutlet UILabel *createdTimeLabel;
@property (nonatomic, retain) Note *note;
@property (nonatomic, assign) BOOL flagInsert;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) UIPickerView *feelPicker;

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)feelingButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)mapButtonPressed:(id)sender;
- (IBAction)imageButtonPressed:(id)sender;

@end
