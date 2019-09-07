//
//  DisplayConfigurationCell.m
//  DisplayWatcherPane
//
//  Created by James Elliott on Sun Apr 11 2004.
//  Copyright © 2004-2019 Deep Symmetry, LLC. All rights reserved.
//

#import "DisplayConfigurationCell.h"
#import "DisplayPosition.h"


@implementation DisplayConfigurationCell

- (id)init
{
    self = [super initImageCell:nil];
    if (self) {
//        NSLog(@"DisplayConfigurationCell initialized ok");
    }
    return self;
}

- (void) drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect insetFrame = NSInsetRect(cellFrame, 2.0, 2.0);
	NSAffineTransform *transform = [self calculateTransformToFrame:insetFrame];	
	
	// Draw a scaled representation of the display configuration in our frame
	NSArray *displays = [self objectValue];
	DisplayPosition *aPosition;
	NSEnumerator *enumerator = [displays objectEnumerator];
	NSColor *monitorColor = [NSColor colorWithDeviceRed:0.32 green:0.54 blue:0.8 alpha:1.0];
	BOOL menuBarDone = NO;
	
	while (aPosition = [enumerator nextObject]) {
		NSBezierPath *path = [NSBezierPath bezierPathWithRect:[aPosition frame]];
		path = [transform transformBezierPath:path];
		[monitorColor set];
		[path fill];
		[[NSColor blackColor] set];
		[path stroke];
		
		if (!menuBarDone) {
			NSRect menuFrame = [aPosition frame];
			menuFrame.origin.y = menuFrame.origin.y + menuFrame.size.height * 0.9;
			menuFrame.size.height = menuFrame.size.height / 10.0;
			path = [NSBezierPath bezierPathWithRect:menuFrame];
			path = [transform transformBezierPath:path];
			[[NSColor whiteColor] set];
			[path fill];
			[[NSColor blackColor] set];
			[path stroke];
			menuBarDone = YES;
		}
	}

}

- (NSAffineTransform *)calculateTransformToFrame:(NSRect)cellFrame
{
	NSAffineTransform *result = [NSAffineTransform transform];
	
	// First we need to flip the vertical axis, since screens have the origin at the lower left,
	// while NSTableCell puts the origin at the top left.
	[result scaleXBy:1.0 yBy:-1.0];
	
	// Calculate the bounding box of all the displays we're trying to draw
	NSArray *displays = [self objectValue];
	NSRect displayBounds = NSMakeRect(0.0, 0.0, 0.0, 0.0); 
	DisplayPosition *aPosition;
	NSEnumerator *enumerator = [displays objectEnumerator];
	while (aPosition = [enumerator nextObject]) {
//			NSLog(@"screen bounds: x=%f, y=%f, w=%f, h=%f", [aPosition frame].origin.x, [aPosition frame].origin.y,
//					[aPosition frame].size.width, [aPosition frame].size.height);
			displayBounds = NSUnionRect(displayBounds, [aPosition frame]);
//			NSLog(@"display bounds: x=%f, y=%f, w=%f, h=%f", displayBounds.origin.x, displayBounds.origin.y,
//					displayBounds.size.width, displayBounds.size.height);
	}
	
//	NSLog(@"cell frame: x=%f, y=%f, w=%f, h=%f", cellFrame.origin.x, cellFrame.origin.y,
//			cellFrame.size.width, cellFrame.size.height);

	// Determine whether the X or Y scaling is more constraining, and scale appropriately
	NSAffineTransform *nextTransform = [NSAffineTransform transform];
	
	float xScale = displayBounds.size.width / cellFrame.size.width;
	float yScale = displayBounds.size.height / cellFrame.size.height;
	if (xScale > yScale) {
//		NSLog(@"Scaling by %f", 1.0/xScale);
		[nextTransform scaleBy:1.0/xScale];
	} else {
//		NSLog(@"Scaling by %f", 1.0/yScale);
		[nextTransform scaleBy:1.0/yScale];
	}
	[nextTransform translateXBy:-displayBounds.origin.x yBy:displayBounds.size.height +
		displayBounds.origin.y];
	[result appendTransform:nextTransform];

	// Now append a transform to shift to the actual frame coordinates
	nextTransform = [NSAffineTransform transform];
	[nextTransform translateXBy:cellFrame.origin.x yBy:cellFrame.origin.y];
	[result appendTransform:nextTransform];

	return result;
}


@end
