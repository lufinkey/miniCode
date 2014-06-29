
#import "FontSelectorViewController.h"
#import "GlobalPreferences.h"

@implementation FontSelectorViewController

- (id)init
{
	if([super init]==nil)
	{
		return nil;
	}
	
	fontFamilyNames = [[NSMutableArray alloc] initWithArray:[UIFont familyNames]];
	fontNames = [[NSMutableArray alloc] init];
	
	for(int i=0; i<[fontFamilyNames count]; i++)
	{
		NSString* familyName = [fontFamilyNames objectAtIndex:i];
		[fontNames addObject:[UIFont fontNamesForFamilyName:familyName]];
	}
	
	fontTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
	fontTable.delegate = self;
	fontTable.dataSource = self;
	[self.view addSubview:fontTable];
	
	[self.navigationItem setTitle:@"Fonts"];
	
	return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return YES;
}

- (void)resetLayout
{
	[super resetLayout];
	[fontTable setFrame:CGRectMake(0,0, self.view.bounds.size.width, self.view.bounds.size.height)];
}

- (void)dealloc
{
	[fontFamilyNames release];
	[fontNames release];
	[fontTable release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return [fontFamilyNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [fontFamilyNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[fontNames objectAtIndex:section] count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* cellID = [[fontNames objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if(cell==nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
	}
	
	[cell.textLabel setText:cellID];
	
	return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	NSString* fontName = [[fontNames objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	GlobalPreferences_setCodeEditorFont([fontName UTF8String]);
	
	[self.navigationController popViewControllerAnimated:YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
