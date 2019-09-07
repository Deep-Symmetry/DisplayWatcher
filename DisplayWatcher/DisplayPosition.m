//
//  DisplayPosition.m
//  DisplayWatcher
//
//  Created by James Elliott on Sat Apr 10 2004.
//  Copyright © 2004-2019, Deep Symmetry, LLC. All rights reserved.
//

#import "DisplayPosition.h"


@implementation DisplayPosition

// Build an instance that represents a screen position corresponding to the
// specified frame. The return value is autoreleased.
- (id) initWithFrame:(NSRect)aFrame
{
	if (self = [super init]) {
		frame = aFrame;
	}
	return self;
}

// Accessor for the frame we're representing
- (NSRect) frame
{
	return frame;
}

// Compare whether a screen position is "close enough" to the one we represent.
// The width and height must match exactly, but the X and Y positions are allowed
// do differ by the specified number of pixels.
- (BOOL) matches:(NSRect)aFrame withTolerance:(float)aTolerance
{
	if (aFrame.size.width != frame.size.width) return NO;
	if (aFrame.size.height != frame.size.height) return NO;
	if (fabs(aFrame.origin.x - frame.origin.x) > fabs(aTolerance)) return NO;
	if (fabs(aFrame.origin.y - frame.origin.y) > fabs(aTolerance)) return NO;
	return YES;
}

#pragma mark NSCoding protocol

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeFloat:frame.origin.x forKey:@"x"];
	[coder encodeFloat:frame.origin.y forKey:@"y"];
	[coder encodeFloat:frame.size.width forKey:@"width"];
	[coder encodeFloat:frame.size.height forKey:@"height"];
}

- (id) initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		frame.origin.x = [coder decodeFloatForKey:@"x"];
		frame.origin.y = [coder decodeFloatForKey:@"y"];
		frame.size.width = [coder decodeFloatForKey:@"width"];
		frame.size.height = [coder decodeFloatForKey:@"height"];
	}
	return self;
}

@end
