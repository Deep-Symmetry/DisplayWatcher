//
//  FileIconCell.h
//
//  Created by James Elliott on Sun Apr 11 2004.
//  Copyright © 2004-2019, Deep Symmetry, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileIconCell : NSTextFieldCell {
}

- (NSImage *)image;

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
- (NSSize)cellSize;

@end
