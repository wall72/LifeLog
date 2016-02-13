//
//  AnalyticsViewController.m
//  LifeLog
//
//  Created by Changho Lee on 11. 6. 22..
//  Copyright 2011 타임교육. All rights reserved.
//

#import "AnalyticsViewController.h"
#import "AnalyticsDetailViewController.h"

@implementation AnalyticsViewController

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

#pragma mark - Event handlers

- (IBAction)showOutcome:(id)sender {
    AnalyticsDetailViewController *_analyticsDetailViewController = [[AnalyticsDetailViewController alloc] initWithNibName:@"AnalyticsDetailViewController" bundle:nil];
    [_analyticsDetailViewController setTitle:@"Outcome"];
    [_analyticsDetailViewController setAnalyticsFlag:YES];
    [self.navigationController pushViewController:_analyticsDetailViewController animated:YES];
    [_analyticsDetailViewController release];
}

- (IBAction)showFeeling:(id)sender {
    AnalyticsDetailViewController *_analyticsDetailViewController = [[AnalyticsDetailViewController alloc] initWithNibName:@"AnalyticsDetailViewController" bundle:nil];
    [_analyticsDetailViewController setTitle:@"Feeling"];
    [_analyticsDetailViewController setAnalyticsFlag:NO];
    [self.navigationController pushViewController:_analyticsDetailViewController animated:YES];
    [_analyticsDetailViewController release];
}

@end
