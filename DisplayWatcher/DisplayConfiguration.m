//
//  DisplayConfiguration.m
//  DisplayWatcher
//
//  Created by James Elliott on Sat Apr 10 2004.
//  Copyright © 2004-2019 Deep Symmetry, LLC. All rights reserved.
//
// Encapsulates the information needed to recognize a particular display configuration, as well
// as the path of the file to be opened when that configuration is detected.

#import "DisplayConfiguration.h"
#import "DisplayPosition.h"

@implementation DisplayConfiguration

#pragma mark Basic object management

- (id)init
{
	if (self = [super init]) {
		name = @"";
		displays = [[NSMutableArray alloc] init];
		tolerance = 10;
		fileToOpen = @"";
	}
	return self;
}

- (void)dealloc
{
	[name release];
	[displays release];
	[fileToOpen release];
	[super dealloc];
}

#pragma mark Useful behavior

- (void)recordCurrentConfiguration
{
	NSArray * screens = [NSScreen screens];
	unsigned long numScreens = [screens count];
	unsigned i;

//	NSLog(@"Total screens: %d", numScreens);
	for (i = 0; i < numScreens; i++) {
//		NSLog(@"  Geometry for screen %d:", i);
		NSScreen *screen = [screens objectAtIndex: i];
		NSRect frame = [screen frame];
		
		id aPosition = [[DisplayPosition alloc] initWithFrame:frame];
		[displays addObject:aPosition];
		
//		NSLog(@"    Origin: (%f, %f), Width: %f, Height: %f",
//			frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	}
}

- (BOOL)matchesCurrentConfiguration
{
	NSArray * screens = [NSScreen screens];
	unsigned long numScreens = [screens count];
	unsigned i;

	if (numScreens != [displays count])
		return NO;
	for (i = 0; i < numScreens; i++) {
		NSScreen *screen = [screens objectAtIndex:i];
		DisplayPosition *aPosition = [displays objectAtIndex:i];
		if (![aPosition matches:[screen frame] withTolerance:tolerance])
			return NO;
	}
	return YES;
}

#pragma mark Accessors

- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	[aName retain];
	[name release];
	name = aName;
}

- (float)tolerance
{
	return tolerance;
}

- (void)setTolerance:(float)aTolerance
{
	tolerance = aTolerance;
}

- (NSString *)fileToOpen
{
	return fileToOpen;
}

- (void)setFileToOpen:(NSString *)aPath
{
	[aPath retain];
	[fileToOpen release];
	fileToOpen = aPath;
}

- (NSArray *)displays
{
	return displays;
}


- (NSImage *) configImage
{
	return nil;
}

- (NSImage *) fileImage
{
	if ([fileToOpen length] < 1) {
		return nil;
	}
	return [[NSWorkspace sharedWorkspace] iconForFile:fileToOpen];
}


#pragma mark NSCoding protocol

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:name forKey:@"name"];
	[coder encodeObject:displays forKey:@"displays"];
	[coder encodeFloat:tolerance forKey:@"tolerance"];
	[coder encodeObject:fileToOpen forKey:@"fileToOpen"];
}

- (id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		name = [[coder decodeObjectForKey:@"name"] retain];
		displays = [[coder decodeObjectForKey:@"displays"] retain];
		tolerance = [coder decodeFloatForKey:@"tolerance"];
		fileToOpen = [[coder decodeObjectForKey:@"fileToOpen"] retain];
		
	}
	return self;
}

@end
