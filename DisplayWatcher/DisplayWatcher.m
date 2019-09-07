//
//  DisplayWatcher.m
//  DisplayWatcher
//
//  Created by Jim Elliott on Sat Apr 10 2004.
//  Copyright (c) 2004 Brunch Boy Design. All rights reserved.
//

#import "DisplayWatcher.h"
#import "DisplayConfiguration.h"

// The key used to look up our list of recognized configurations in the preferences
NSString *ConfigurationsKey = @"Configurations";
NSString *LastConfigKey = @"LastConfiguration";

// The keys used to determine behavior on "switching" to the same configuration
NSString *IgnoreKey = @"IgnoreSwitchingToSame";
NSString *EvenAfterKey = @"IgnoreEvenAfterUnrecognized";

// The keys used to look up files to open on sleep/awake events in the preferences
NSString *LaunchOnSleepKey = @"LaunchOnSleep";
NSString *LaunchOnWakeKey = @"LaunchOnWake";

@implementation DisplayWatcher

+ (void)initialize
{
	// Set up the default preferences: An empty list of configurations
	NSMutableArray *empty = [NSMutableArray array];
	NSData *emptyAsData = [NSKeyedArchiver archivedDataWithRootObject:empty];
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionaryWithObject:emptyAsData
		forKey:ConfigurationsKey];
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
//	NSLog(@"Registered defaults: %@", defaultValues);
}

// Set up to receive high-level notifications
- (id)init
{
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
			selector:@selector(handleDisplayGeometryChange:)
			    name:NSApplicationDidChangeScreenParametersNotification object:nil];
//		NSLog(@"Registered with AppKit notification center");
//		[[NSNotificationCenter defaultCenter] addObserver:self
//			selector:@selector(handleSleeping:) name:NSWorkspaceWillSleepNotification
//			  object:nil];
		[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
			selector:@selector(handleAwoke:) name:NSWorkspaceDidWakeNotification
			  object:nil];
	}
	
	// React to the initial display configuration
	[self handleDisplayGeometryChange: nil];
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
//	NSLog(@"Unregistered with notification centers");
	[super dealloc];
}

// Helper method that tries to cause the specified file to be launched as if the user
// had double-clicked it in the Finder. Displays an error dialog if this fails. The
// path may be empty, in which case nothing is attemped and no error is displayed.
- (void)launchFileWithPath:(NSString *)aPath
{
	if ([aPath length] > 0) {
		if (![[NSWorkspace sharedWorkspace] openFile:aPath]) {
			NSRunAlertPanel(@"DisplayWatcher Configuration Problem",
				@"Unable to open specified file, %@", @"Darn", nil, nil, aPath);
		}
	}
}

#pragma mark Display configuration notifications

- (void)handleDisplayGeometryChange:(NSNotification *)note
{
//	NSLog(@"Got notification: %@", note);

	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// If we're ignoring "switches" to identical configurations, check whether the
	// current configuration is the same one we last saw
	if ([[NSUserDefaults standardUserDefaults] boolForKey:IgnoreKey]) {
		NSData *configData = [[NSUserDefaults standardUserDefaults] objectForKey:LastConfigKey];
		if (configData != nil) {
			// There is a previous configuration to compare
			DisplayConfiguration *lastConfiguration = [NSKeyedUnarchiver unarchiveObjectWithData:configData];
			if ([lastConfiguration matchesCurrentConfiguration]) {
//				NSLog(@"Ignoring switch to same configuration");
				return;
			}
		}
	}
	
	NSData *configData = [[NSUserDefaults standardUserDefaults] objectForKey:ConfigurationsKey];
//	NSLog(@"Found configData: %@", configData);
	NSMutableArray *configurations = [NSKeyedUnarchiver unarchiveObjectWithData:configData];
	[configurations retain];
	
	// See if we recognize the current configuration
	NSEnumerator *enumerator = [configurations objectEnumerator];
	DisplayConfiguration *aConfiguration;
	while (aConfiguration = [enumerator nextObject]) {
//		NSLog(@"Testing %@", aConfiguration);
		if ([aConfiguration matchesCurrentConfiguration]) {
			NSLog(@"%@ Matches!", [aConfiguration name]);
			
			// Note that we last saw this configuration, in case we're to ignore spurious switches to it
			[[NSUserDefaults standardUserDefaults]
				setObject:[NSKeyedArchiver archivedDataWithRootObject:aConfiguration] forKey:LastConfigKey];
				
			// Open the file associated with the configuration we matched
			[self launchFileWithPath:[aConfiguration fileToOpen]];
			
			return;
		}
	}
	
	// We did not recognize the configuration. If the user preferences tell us that this is supposed
	// to make us react to a switch back to a recognized configuration, even if it's the same as the
	// last recognized configuration, then it's time to clear our notion of the last configuration.
	if (![[NSUserDefaults standardUserDefaults] boolForKey:EvenAfterKey]) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:LastConfigKey];
	}
}

#pragma mark Power management notifications

// We've been told we're about to sleep
- (void)handleSleeping:(NSNotification *)note
{
	[self launchFileWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:LaunchOnSleepKey]];
}

// We've been told we just woke up
- (void)handleAwoke:(NSNotification *)note
{
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self launchFileWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:LaunchOnWakeKey]];
//	NSLog(@"Got wake notification");
}

@end
