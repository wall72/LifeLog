//
//  TimeSpanViewController.m
//  LifeLog
//
//  Created by cliff on 11. 4. 6..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "TimeSpanViewController.h"
#import "LifeLogAppDelegate.h"

@implementation TimeSpanViewController

@synthesize timeSpan = __timeSpan;
@synthesize keys = __keys;
@synthesize lastIndexPath = __lastIndexPath;

- (id)initWithStyle:(UITableViewStyle)style {
    NSLog(@"Call");
    
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    NSLog(@"Call");
    
    [__timeSpan release];
    [__keys release];
    [__lastIndexPath release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"Call");
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    NSLog(@"Call");
    
    [super viewDidLoad];
}

- (void)viewDidUnload {
    NSLog(@"Call");
    
    [super viewDidUnload];
    self.timeSpan = nil;
    self.keys = nil;
    self.lastIndexPath = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"Call");
    
    [super viewWillAppear:animated];

    self.keys = [self.timeSpan.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"Call");
    
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"Call");
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Call");
    
    return [self.timeSpan count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    static NSString *_cellIdentifier = @"Cell";
    
    UITableViewCell *_cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if (_cell == nil) {
        _cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:_cellIdentifier] autorelease];
    }
    
    NSString *_key = [self.keys objectAtIndex:indexPath.row];
    [_cell.textLabel setText:_key];
    
    if ([[self.timeSpan objectForKey:_key] boolValue]) {
        [_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        [self setLastIndexPath:indexPath];
    } else {
        [_cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return _cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    return NO;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Call");
    
    int _row = [indexPath row];
    int _oldRow = [self.lastIndexPath row];
    NSString *_key;
    if (_row != _oldRow) {
        UITableViewCell *_newCell = [tableView cellForRowAtIndexPath:indexPath];
        [_newCell setAccessoryType:UITableViewCellAccessoryCheckmark];
        _key = [self.keys objectAtIndex:_row];
        [self.timeSpan setObject:@"1" forKey:_key];
        
        UITableViewCell *_oldCell = [tableView cellForRowAtIndexPath:self.lastIndexPath]; 
        [_oldCell setAccessoryType:UITableViewCellAccessoryNone];
        _key = [self.keys objectAtIndex:_oldRow];
        [self.timeSpan setObject:@"0" forKey:_key];
        
        [self setLastIndexPath:indexPath];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
