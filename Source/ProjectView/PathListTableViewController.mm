
#import "PathListTableViewController.h"

@interface PathListTableViewController()
- (void)resetLayout;
- (void)onCloseButtonSelected;
- (void)onEditButtonSelected;
- (void)onDoneButtonSelected;
@end


@implementation PathListTableViewController

@synthesize delegate;

@synthesize pathTable;
@synthesize pathArray;
@synthesize navigationBar;

- (id)initWithPaths:(NSArray*)paths delegate:(id<PathListTableViewControllerDelegate>)del
{
	delegate = del;
	
	if([super init]==nil)
	{
		return nil;
	}
	
	navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
	[self.view addSubview:navigationBar];
	
	UINavigationItem*navItem = [[UINavigationItem alloc] initWithTitle:@""];
	UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(onCloseButtonSelected)];
	[navItem setLeftBarButtonItem:closeButton animated:NO];
	[closeButton release];
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonSelected)];
	[navItem setRightBarButtonItem:editButton animated:NO];
	[editButton release];
	NSArray* navItems = [[NSArray alloc] initWithObjects:navItem, nil];
	[navItem release];
	[navigationBar setItems:navItems animated:NO];
	[navItems release];
	
	pathArray = [[NSMutableArray alloc] initWithArray:paths];
	CGRect pathTableFrame = CGRectMake(0,navigationBar.frame.size.height,self.view.frame.size.width,self.view.frame.size.height-navigationBar.frame.size.height);
	pathTable = [[UITableView alloc] initWithFrame:pathTableFrame style:UITableViewStylePlain];
	[pathTable setAllowsSelectionDuringEditing:YES];
	pathTable.delegate = self;
	pathTable.dataSource = self;
	[self.view addSubview:pathTable];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self resetLayout];
}

- (void)resetLayout
{
	[navigationBar setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
	CGRect pathTableFrame = CGRectMake(0,navigationBar.frame.size.height,self.view.bounds.size.width,self.view.bounds.size.height-navigationBar.frame.size.height);
	[pathTable setFrame:pathTableFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self resetLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	if(delegate!=nil && [delegate respondsToSelector:@selector(pathListController:viewWillDisappear:)])
	{
		[delegate pathListController:self viewWillDisappear:animated];
	}
}

- (void)removePathAtIndex:(NSUInteger)index
{
	[pathArray removeObjectAtIndex:index];
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:0];
	NSArray* indexes = [[NSArray alloc] initWithObjects:indexPath, nil];
	[pathTable deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationBottom];
	[indexes release];
}

- (void)setPathArray:(NSArray*)array
{
	if(array!=pathArray)
	{
		[pathArray release];
		pathArray = [[NSMutableArray alloc] initWithArray:array];
		[pathTable reloadData];
	}
}

- (void)onCloseButtonSelected
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)onEditButtonSelected
{
	[pathTable setEditing:YES animated:YES];
	[navigationBar.topItem setLeftBarButtonItem:nil animated:YES];
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(onDoneButtonSelected)];
	[navigationBar.topItem setRightBarButtonItem:doneButton animated:YES];
	[doneButton release];
}

- (void)onDoneButtonSelected
{
	[pathTable setEditing:NO animated:YES];
	
	UIBarButtonItem* closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleBordered target:self action:@selector(onCloseButtonSelected)];
	[navigationBar.topItem setLeftBarButtonItem:closeButton animated:YES];
	[closeButton release];
	
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(onEditButtonSelected)];
	[navigationBar.topItem setRightBarButtonItem:editButton animated:YES];
	[editButton release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [pathArray count];
}

- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if(delegate!=nil && [delegate respondsToSelector:@selector(pathListController:shouldRemovePathAtIndex:)])
	{
		if([delegate pathListController:self shouldRemovePathAtIndex:indexPath.row])
		{
			[self removePathAtIndex:indexPath.row];
			
			if([delegate respondsToSelector:@selector(pathListController:didRemovePathAtIndex:)])
			{
				[delegate pathListController:self didRemovePathAtIndex:indexPath.row];
			}
		}
	}
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSNumber* num = [[NSNumber alloc] initWithInt:indexPath.row];
	NSString* cellID = [[num stringValue] retain];
	[num release];
	
	UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	
	[cellID release];
	
	[cell.textLabel setText:[pathArray objectAtIndex:indexPath.row]];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(delegate!=nil && [delegate respondsToSelector:@selector(pathListController:didSelectPathAtIndex:)])
	{
		[delegate pathListController:self didSelectPathAtIndex:indexPath.row];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
	[pathTable release];
	[pathArray release];
	[navigationBar release];
	[super dealloc];
}

@end
