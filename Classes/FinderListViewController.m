//
//  FinderListViewController.m
//  LifeLog
//
//  Created by cliff on 11. 3. 9..
//  Copyright 2011 teamzepa. All rights reserved.
//

#import "FinderListViewController.h"
#import "LifeLogAppDelegate.h"
#import "DetailViewController.h"
#import "ListCell.h"
#import "Note.h"
#import "Resource.h"
#import "Utils.h"
#import "Global.h"

@interface FinderListViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope;
@end

@implementation FinderListViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
	NSLog(@"call");
	
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	NSLog(@"call");
	
    [__fetchedResultsController release];
    [__managedObjectContext release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	NSLog(@"call");

	LifeLogAppDelegate *_appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.managedObjectContext = _appDelegate.managedObjectContext;
	
    [super viewDidLoad];
}

- (void)viewDidUnload {
	NSLog(@"call");
    
    [super viewDidUnload];
//    self.fetchedResultsController = nil;
//    self.managedObjectContext = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"call");
	
    [super viewWillAppear:animated];

    [self.tableView setRowHeight:57];
	[self.tableView reloadData];
    
    [self.searchDisplayController.searchResultsTableView setRowHeight:57];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"call");
	
    [super viewDidAppear:animated];
     
    [self.tableView setContentOffset:CGPointMake(0, 44) animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSLog(@"call");
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	NSLog(@"call");
	
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSLog(@"call");
	
    id <NSFetchedResultsSectionInfo> _sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [_sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    static NSString *_customCellIdentifier = @"ListCellIdentifier ";
    
    ListCell *_cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:_customCellIdentifier];
    if (_cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ListCell" owner:self options:nil];
        for (id oneObject in nib) {
            if ([oneObject isKindOfClass:[ListCell class]]) {
                _cell = (ListCell *)oneObject;
            }
        }
    }

    [self configureCell:_cell atIndexPath:indexPath];
    
    return _cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		Note *_note = [self.fetchedResultsController objectAtIndexPath:indexPath];
		
        [_note setActive:[NSNumber numberWithBool:NO]];
        
        int64_t _epoch_time = ([[NSDate date] timeIntervalSince1970] * 1000);
        [_note setUpdated_time:[NSNumber numberWithLongLong:_epoch_time]];
        
        [_note setUpdate_count:[NSNumber numberWithInt:[_note.update_count intValue] + 1]];
        
        [Utils deleteDirectory:_note.uuid];

        LifeLogAppDelegate *appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate saveContext];
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
    return NO;
}

#pragma mark - Table view delegate

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	NSLog(@"call");
	
	return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSLog(@"call");
	
	// create the parent view that will hold header Label
	UIView *_customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)] autorelease];
	
	// create the button object
	UILabel *_headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	[_headerLabel setBackgroundColor:[UIColor grayColor]];
	[_headerLabel setOpaque:YES];
	[_headerLabel setTextColor:[UIColor whiteColor]];
	[_headerLabel setHighlightedTextColor:[UIColor whiteColor]];
    [_headerLabel setShadowColor:[UIColor darkGrayColor]];
    [_headerLabel setShadowOffset:CGSizeMake(1, 1)];
	[_headerLabel setFont:[UIFont boldSystemFontOfSize:12]];
    [_headerLabel setTextAlignment:UITextAlignmentCenter];
	[_headerLabel setFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)];
    
    id <NSFetchedResultsSectionInfo> _theSection = [[self.fetchedResultsController sections] objectAtIndex:section];
	
	[_headerLabel setText:[_theSection name]];
    
	[_customView addSubview:_headerLabel];
    [_headerLabel release];
    
	return _customView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
	DetailViewController *_detailViewController = [[DetailViewController alloc] init];
    [_detailViewController setNote:[[self fetchedResultsController] objectAtIndexPath:indexPath]];
	[_detailViewController setHidesBottomBarWhenPushed:YES];
	
    [self.navigationController pushViewController:_detailViewController animated:YES];
    [_detailViewController release];
}

#pragma mark - Search bar delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"call");
	
    [searchBar setText:@""];
}

#pragma mark - Search display delegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	NSLog(@"call");
	
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
	NSLog(@"call");
	
    NSString *_query = self.searchDisplayController.searchBar.text;

    [NSFetchedResultsController deleteCacheWithName:@"List"];
    
    NSFetchRequest *_fetchRequest = [[self fetchedResultsController] fetchRequest];
    
    NSPredicate *_predicate;
    if (_query && _query.length) {
        _predicate = [NSPredicate predicateWithFormat:@"content contains[cd] %@ and active = 1", _query];
        [_fetchRequest setPredicate:_predicate];
    } else {
        _predicate = [NSPredicate predicateWithFormat:@"active = 1"];
        [_fetchRequest setPredicate:_predicate];
    }

    NSError *_error = nil;
    if (![[self fetchedResultsController] performFetch:&_error]) {
        NSLog(@"Unresolved error %@, %@", _error, [_error userInfo]);
        abort();
    }  

	[self.tableView reloadData];
}

#pragma mark - Fetched results controller

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
    
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"active = 1"];
    [_fetchRequest setPredicate:_predicate];

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
																								  sectionNameKeyPath:@"sectionIdentifier"
																										   cacheName:@"List"];
    _aFetchedResultsController.delegate = self;
    self.fetchedResultsController = _aFetchedResultsController;
    
    [_aFetchedResultsController release];
    [_fetchRequest release];
    [_sortDescriptor release];
    [_sortDescriptors release];
    
    NSError *_error = nil;
    if (![self.fetchedResultsController performFetch:&_error]) {
        NSLog(@"Unresolved error %@, %@", _error, [_error userInfo]);
        abort();
    }
    
    return __fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"call");
	
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	NSLog(@"call");
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	NSLog(@"call");
	
    UITableView *_tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	NSLog(@"call");
	
    [self.tableView endUpdates];
}

#pragma mark - Event handler

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	NSLog(@"call");
	
    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    [self.navigationItem.rightBarButtonItem setEnabled:!editing];
}

#pragma mark - User defined fuction

- (void)configureCell:(ListCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"call");
	
	Note *_note = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
    // Set Background Image
    NSString *_disMinute = [_note.log_time substringFromIndex:14];
    NSInteger _disMinuteIdx = [_disMinute isEqualToString:@"30"]?2:1;
    [cell.backgroundImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"list_time_bg_%@_%d.png", [_note.log_time substringWithRange:(NSRange){11, 2}], _disMinuteIdx]]];
    
    // Set Feeling
    LifeLogAppDelegate *appDelegate = (LifeLogAppDelegate *)[[UIApplication sharedApplication] delegate];    
    [cell.feelingLabel setText:[appDelegate.feelDict objectForKey:_note.feeling]];
    
    // Set Rating Star
    [cell.ratingScoreImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bar_star_s_%d.png", [_note.rating_score intValue]]]];
    
    // Set Log Text
	[cell.contentLabel setText:_note.title];
	
    // Set Accessary
    if ([_note.map_yn boolValue]) {
        [cell.mapYnImage setImage:[UIImage imageNamed:@"daily_time_bar_map_on.png"]];
    }
    if ([_note.facebook_yn boolValue]) {
        [cell.facebookYnImage setImage:[UIImage imageNamed:@"daily_time_bar_facebook_on.png"]];
    }
    
    // Set Line
    [cell.line1Image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bar_line.png"]]];
    [cell.line2Image setImage:[UIImage imageNamed:[NSString stringWithFormat:@"daily_time_bar_line.png"]]];

    // Set Accessary Type
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
}

@end

