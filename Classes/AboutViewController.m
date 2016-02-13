//
//  AboutViewController.m
//  LifeLog
//
//  Created by Changho Lee on 11. 6. 22..
//  Copyright 2011 타임교육. All rights reserved.
//

#import "AboutViewController.h"
#import "Global.h"

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Event handler

- (IBAction)sendEmail:(id)sender {
    MFMailComposeViewController *_mailComposer = [[[MFMailComposeViewController alloc] init] autorelease];
    [_mailComposer setMailComposeDelegate:self];
    [_mailComposer setSubject:@"Hey Guys!"];
    [_mailComposer setMessageBody:@"" isHTML:NO];
    [self presentModalViewController:_mailComposer animated:YES];
}

- (IBAction)goFacebook:(id)sender {
    NSURL *_url = [NSURL URLWithString:FACEBOOK_PAGE_PATH];
    
    [[UIApplication sharedApplication] openURL:_url];
}

@end
