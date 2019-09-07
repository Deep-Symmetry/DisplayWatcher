//
//  DisplayWatcherPanePref.m
//  DisplayWatcherPane
//
//  Created by James Elliott on Sun Apr 11 2004.
//  Copyright © 2004-2019, Deep Symmetry, LLC. All rights reserved.
//

#import "DisplayWatcherPanePref.h"
#import "DisplayConfiguration.h"
#import "DisplayConfigurationCell.h"
#import "FileIconCell.h"


@implementation DisplayWatcherPanePref

// This method is invoked as we are being initialized
- (id)initWithBundle:(NSBundle *)bundle
{
	// Set up the strings used to locate the DisplayWatcher preferences
	if (self = [super initWithBundle:bundle]) {
		loading = NO;
		appId = CFSTR("org.deepsymmetry.DisplayWatcher");
		configKey = CFSTR("Configurations");
		wakeKey = CFSTR("LaunchOnWake");
		ignoreKey = CFSTR("IgnoreSwitchingToSame");
		evenKey = CFSTR("IgnoreEvenAfterUnrecognized");
	}
	return self;
}

// Set up the columns that need to display images, and load the currently known
// display configurations from the preferences
- (void) mainViewDidLoad
{	
	// Temporarily disable preference saves during initialization, otherwise things would get
	// stepped on.
	loading = YES;

	// Set up the special monitor configuration cell for the first column
	NSTableColumn *column = [tableView tableColumnWithIdentifier:@"displays"];
	[column setDataCell:[[[DisplayConfigurationCell alloc] init] autorelease]];
	
	// Set up the special filename-and-icon cell for the file column
	column = [tableView tableColumnWithIdentifier:@"fileToOpen"];
	[column setDataCell:[[[FileIconCell alloc] init] autorelease]];
	
	// Set it up so that double clicking on non-editable table cells tries to assign
	[tableView setDoubleAction:@selector(assignFileToConfig:)];
	[tableView setTarget:self];
	
	// Load the screen configuration properties as they currently stand
	CFPropertyListRef value = CFPreferencesCopyAppValue(configKey, appId);
	if (value && CFGetTypeID(value) == CFDataGetTypeID()) {
		// We found what we're looking for; reconstruct our configurations
		NSData *configData = [NSData dataWithBytes:CFDataGetBytePtr(value) length:CFDataGetLength(value)];
		configurations = [NSKeyedUnarchiver unarchiveObjectWithData:configData];
	} else {
		// No configurations found; start with an empty array
		configurations = [NSMutableArray array];
	}
	if (value) CFRelease(value);
	[configurations retain];
//	NSLog(@"DisplayWatcherPanePref load found %d configurations", [configurations count]);
	[self addCurrentConfigIfNeeded];
	
	// Load the "ignore" checkbox setting
	[ignoreSameButton setState:CFPreferencesGetAppBooleanValue(ignoreKey, appId, NULL)? NSOnState : NSOffState];

	// Load the "even" checkbox setting
	[evenFromButton setState:CFPreferencesGetAppBooleanValue(evenKey, appId, NULL)? NSOnState : NSOffState];
	
	// Load the on-wake action as it currently stands
	value = CFPreferencesCopyAppValue(wakeKey, appId);
	if (value && CFGetTypeID(value) == CFStringGetTypeID()) {
		[textField setStringValue:(NSString *)value];
	}
	if (value) CFRelease(value);

	if ([[textField stringValue] length] > 0) {
		[imageView setImage:[[NSWorkspace sharedWorkspace]iconForFile:[textField stringValue]]];
	}
	
	// Set up the initial state of the buttons
	[self updateUI];
	
	// We're done loading
	loading = NO;
}

// This method is called when the preference pane is about to be activated. Make another scan
// of the display configurations to see if the user has moved monitors around, changed resolutions
// or something. Also add a notification listener so we'll be told if the user has changed monitor
// configurations while our pane is active, so we can react to them immediately.
- (void) willSelect
{
	[self addCurrentConfigIfNeeded];
    [[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(handleDisplayGeometryChange:)
	    name:NSApplicationDidChangeScreenParametersNotification object:nil];
	[self updateUI];
}

// This method is called when the preference pane is being deactivated. Either another pane
// has been chosen, or the System Preferences application is shutting down. Make sure we've
// saved the current preferences, and unregister our event listener.
- (void) didUnselect
{
	[self updatePreferences];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Display configuration notifications

// This method is called if the user has changed display configurations while our pane is active.
// It gives us an opportunity to update our notion of the current configuration, adding a new one
// if we've not seen this one before.
- (void)handleDisplayGeometryChange:(NSNotification *)note
{
	[self addCurrentConfigIfNeeded];
	[self updateUI];
}

#pragma mark Action methods (configurations)

// The forget button has been pressed. Remove the corresponding configuration.
- (IBAction) forgetConfiguration:(id)sender
{
	if ([tableView selectedRow] >= 0) {
		NSBeginAlertSheet(
			@"Do you really want to forget the selected configuration?", // sheet message
			@"Forget",					// default button label
			nil,						// no third button
			@"Cancel",                  // other button label
			[[self mainView] window],   // window sheet is attached to
			self,						// we’ll be our own delegate
			@selector(confirmForgetSheetDidEnd:returnCode:contextInfo:), // callback
			NULL,						// no need for did-dismiss selector
			sender,						// context info
			@"There is no undo for this operation.",                     // additional text
			nil);						// no parameters in message
	} else {
		NSLog(@"Tried to forget a nonexistent configuration. Should never get here.");
		NSBeep();
	}
}

// The user confirmed removal of a configuration
- (void)confirmForgetSheetDidEnd: (NSWindow *)sheet returnCode: (int)returnCode
	contextInfo: (void *)contextInfo
{
	if (returnCode == NSAlertDefaultReturn) {
		[configurations removeObjectAtIndex:[tableView selectedRow]];
		[tableView deselectAll:self];
		[self addCurrentConfigIfNeeded];
		[tableView reloadData];
	}
}

// The user chose to assign a file to a configuration.
- (IBAction) assignFileToConfig:(id)sender
{
	if ([tableView selectedRow] >= 0) {
		NSOpenPanel *panel = [NSOpenPanel openPanel];
		[panel setPrompt:@"Assign"];
		[panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[[self mainView] window]
			modalDelegate:self didEndSelector:@selector(openPanelForConfigDidEnd:returnCode:contextInfo:)
			contextInfo:nil];
	}
	// Ignore double-clicks in unassigned rows without beeping
}

// The user has finished selecting a file to assign to a configuration
- (void) openPanelForConfigDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode
	contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {  // They confirmed
		[[configurations objectAtIndex:[tableView selectedRow]] setFileToOpen:[openPanel filename]];
	}
	[tableView reloadData];
}

// The user has clicked on the "Ignore 'switching' to an identical configuration" button.
- (IBAction) toggleIgnoreSwitching:(id)sender
{
	[self updateUI];
}

- (IBAction) toggleEvenFromUnrecognized:(id)sender
{
	[self updateUI];
}


#pragma mark Action methods (wake)

// The clear button has been pressed. Offer to remove the wake-up action.
- (IBAction) clearWakeAction:(id)sender
{
	if ([[textField stringValue] length] > 0) {
		NSBeginAlertSheet(
			@"Do you really want to clear the on-wake action?", // sheet message
			@"Clear",					// default button label
			nil,						// no third button
			@"Cancel",                  // other button label
			[[self mainView] window],   // window sheet is attached to
			self,						// we’ll be our own delegate
			@selector(confirmClearSheetDidEnd:returnCode:contextInfo:),       // callback
			NULL,						// no need for did-dismiss selector
			sender,						// context info
			@"There is no undo for this operation.",                     // additional text
			nil);						// no parameters in message
	} else {
		NSLog(@"Tried to clear an  empty wake action. Should never get here.");
		NSBeep();
	}
}

// The user confirmed deletion of the wake action
- (void)confirmClearSheetDidEnd: (NSWindow *)sheet returnCode: (int)returnCode
	contextInfo: (void *)contextInfo
{
	if (returnCode == NSAlertDefaultReturn) {
		[textField setStringValue:@""];
		[imageView setImage:nil];
		[self updateUI];
	}
}

// The user chose to assign a file for the wake action.
- (IBAction) assignFileOnWake:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	[panel setPrompt:@"Assign"];
	[panel beginSheetForDirectory:nil file:nil types:nil modalForWindow:[[self mainView] window]
		modalDelegate:self didEndSelector:@selector(openPanelForWakeDidEnd:returnCode:contextInfo:)
		contextInfo:nil];
}

// The user has finished selecting a file to assign to the wake action
- (void) openPanelForWakeDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode
	contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton) {  // They confirmed
		[textField setStringValue:[openPanel filename]];
		[imageView setImage:[[NSWorkspace sharedWorkspace]iconForFile:[openPanel filename]]];
		[self updateUI];
	}
}

#pragma mark Data source methods

// Determine how many rows the table should contain, based on how many configurations exist
- (int) numberOfRowsInTableView:(NSTableView *)aTableView
{
	return (int)[configurations count];
}

// Get the value for a table cell from the appropriate configuration entry, using the
// column's identifier to look up an appropriate property value
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
	row:(int)rowIndex
{
	DisplayConfiguration *aConfig = [configurations objectAtIndex:rowIndex];
	return [aConfig valueForKey:[aTableColumn identifier]];
}

// A table cell has been edited; update the corresponding configuration entry, using
// the column's identifier to select the property to be changed.
- (void) tableView:(NSTableView *)aTableView setObjectValue:(id)anObject
	forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	DisplayConfiguration *aConfig = [configurations objectAtIndex:rowIndex];
	[aConfig takeValue:anObject forKey:[aTableColumn identifier]];
}

#pragma mark NSTableView delegate methods

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self updateUI];
}

#pragma mark Private methods

// If the current display configuration isn't represented in our list of known
// configurations, create a new untitled row to represent it.
- (void) addCurrentConfigIfNeeded
{
	// See if we recognize the current configuration
	NSEnumerator *enumerator = [configurations objectEnumerator];
	DisplayConfiguration *aConfiguration;
	BOOL matched = NO;
	while ((aConfiguration = [enumerator nextObject]) && !matched) {
//		NSLog(@"Testing %@", aConfiguration);
		if ([aConfiguration matchesCurrentConfiguration]) {
//			NSLog(@"%@ Matches!", [aConfiguration name]);
			matched = YES;
		}
	}

	if (!matched) {  // The current screenconfiguration is new, so add it to the list
		DisplayConfiguration *aConfiguration = [[DisplayConfiguration alloc] init];
		[aConfiguration setName:@"untitled"];
		[aConfiguration recordCurrentConfiguration];
		[configurations addObject:aConfiguration];
		[aConfiguration release];
		[tableView reloadData];
		
		// Select the new configuration, since it's what they'll probably want to edit
		[tableView selectRow:[configurations count]-1 byExtendingSelection:NO];
	}
}

// Save the current set of configurations to the user preferences
- (void) updatePreferences
{
	NSData *configAsData = [NSKeyedArchiver archivedDataWithRootObject:configurations];
	CFPreferencesSetAppValue(configKey, configAsData, appId);

	CFBooleanRef checked = ([ignoreSameButton state] == NSOnState)? kCFBooleanTrue : kCFBooleanFalse;
	CFPreferencesSetAppValue(ignoreKey, checked, appId);
	checked = ([evenFromButton state] == NSOnState)? kCFBooleanTrue : kCFBooleanFalse;
	CFPreferencesSetAppValue(evenKey, checked, appId);

	CFPreferencesSetAppValue(wakeKey, [textField stringValue], appId);

	CFPreferencesAppSynchronize(appId);
}

// Update the user interface to reflect currently available actions
- (void) updateUI
{
	// Update the configuration table buttons
	BOOL enabled = YES;
	if ([tableView selectedRow] < 0) {
		enabled = NO;
	}
	[assignButton setEnabled:enabled];
	
	// If the Forget button would otherwise be enabled, but the selected configuration is
	// the active configuration, disable it, because you can't forget the active configuration.
	if (enabled)
	{
		if ([[configurations objectAtIndex:[tableView selectedRow]] matchesCurrentConfiguration])
		{
			enabled = NO;
		}
	}
	[forgetButton setEnabled:enabled];
	
	// Update the "ignore" checkboxes
	if ([ignoreSameButton state] == NSOnState) {
		[evenFromButton setEnabled:YES];
	} else {
		[evenFromButton setState:NSOffState];
		[evenFromButton setEnabled:NO];
	}
	
	// Update the on-wake action elements
	enabled = [[textField stringValue] length] > 0;
	[clearWakeButton setEnabled:enabled];
	
	// Finally, save the current preferences, in case the user is playing and testing
	if (!loading) {
		[self updatePreferences];
	}
}

@end
