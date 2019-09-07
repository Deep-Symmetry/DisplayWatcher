//
//	ImageAndTextCell.m
//  Created by James Elliott on Sun Apr 11 2004.
//  Copyright © 2004-2019, Deep Symmetry, LLC. All rights reserved.
//
//  Subclass of NSTextFieldCell that holds filenames, and displays
//  the corresponding file icon as well as the name.


#import "FileIconCell.h"

@implementation FileIconCell


// Get the image that is displayed
- (NSImage *) image
{
	if ([[self stringValue] length] < 1)
		return nil;
    return [[NSWorkspace sharedWorkspace] iconForFile:[self stringValue]];
}

- (NSRect) imageFrameForCellFrame:(NSRect)cellFrame
{
    if ([self image] != nil) {
        NSRect imageFrame;
        imageFrame.size = [[self image] size];
        imageFrame.origin = cellFrame.origin;
        imageFrame.origin.x += 3;
        imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);
        return imageFrame;
    }
    else
        return NSZeroRect;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj
	delegate:(id)anObject event:(NSEvent *)theEvent
{
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [[self image] size].width, NSMinXEdge);
    [super editWithFrame: textFrame inView: controlView editor:textObj delegate:anObject event: theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj
	delegate:(id)anObject start:(int)selStart length:(int)selLength
{
    NSRect textFrame, imageFrame;
    NSDivideRect (aRect, &imageFrame, &textFrame, 3 + [[self image] size].width, NSMinXEdge);
    [super selectWithFrame: textFrame inView: controlView editor:textObj delegate:anObject
		start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if ([self image] != nil) {
        NSSize	imageSize;
        NSRect	imageFrame;

        imageSize = [[self image] size];
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, 3 + imageSize.width, NSMinXEdge);
        if ([self drawsBackground]) {
            [[self backgroundColor] set];
            NSRectFill(imageFrame);
        }
        imageFrame.origin.x += 3;
        imageFrame.size = imageSize;

        if ([controlView isFlipped])
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2);
        else
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2);

        [[self image] compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
    }
    [super drawWithFrame:cellFrame inView:controlView];
}

- (NSSize)cellSize {
    NSSize cellSize = [super cellSize];
    cellSize.width += ([self image] ? [[self image] size].width : 0) + 3;
    return cellSize;
}

@end
