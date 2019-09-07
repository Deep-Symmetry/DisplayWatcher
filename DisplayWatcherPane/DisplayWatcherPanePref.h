//
//  DisplayWatcherPanePref.h
//  DisplayWatcherPane
//
//  Created by James Elliott on Sun Apr 11 2004.
//  Copyright © 2004-2019, Deep Symmetry, LLC. All rights reserved.
//

#import <PreferencePanes/PreferencePanes.h>


@interface DisplayWatcherPanePref : NSPreferencePane 
{
	CFStringRef appId;		// Identifies the preferences file used by DisplayWatcher
	CFStringRef configKey;  // Identifies the key by which display configurations are saved
	CFStringRef wakeKey;    // Identifies the key by which the on-wake action is saved
	CFStringRef ignoreKey;  // Identifies the key for the "ignore switching to same" toggle
	CFStringRef evenKey;	// Identifies the key for the "even after unrecognized" toggle
	
	Boolean loading;		// Indicates whether the panel is loading its UI
	
	NSMutableArray *configurations;
	IBOutlet NSTableView *tableView;
	IBOutlet NSButton *forgetButton;
	IBOutlet NSButton *assignButton;
	IBOutlet NSImageView *imageView;
	IBOutlet NSTextField *textField;
	IBOutlet NSButton *ignoreSameButton;
	IBOutlet NSButton *evenFromButton;
	IBOutlet NSButton *clearWakeButton;
	IBOutlet NSButton *assignWakeButton;
}

- (void) mainViewDidLoad;

#pragma mark Action methods (configurations)

- (IBAction) forgetConfiguration:(id)sender;
- (void)confirmForgetSheetDidEnd: (NSWindow *)sheet returnCode: (int)returnCode
        contextInfo: (void *)contextInfo;
- (IBAction) assignFileToConfig:(id)sender;
- (void) openPanelForConfigDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode
	contextInfo:(void *)contextInfo;
- (IBAction) toggleIgnoreSwitching:(id)sender;
- (IBAction) toggleEvenFromUnrecognized:(id)sender;
	
#pragma mark Action methods (wake)

- (IBAction) clearWakeAction:(id)sender;
- (void)confirmClearSheetDidEnd: (NSWindow *)sheet returnCode: (int)returnCode
        contextInfo: (void *)contextInfo;
- (IBAction) assignFileOnWake:(id)sender;
- (void) openPanelForWakeDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode
	contextInfo:(void *)contextInfo;
	
#pragma mark Data source methods

- (int) numberOfRowsInTableView:(NSTableView *)aTableView;
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
	row:(int)rowIndex;
- (void) tableView:(NSTableView *)aTableView setObjectValue:(id)anObject
	forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
	
#pragma mark NSTableView delegate methods

- (void) tableViewSelectionDidChange:(NSNotification *)aNotification;

#pragma mark Private methods

- (void) addCurrentConfigIfNeeded;
- (void) updatePreferences;
- (void) updateUI;

@end
