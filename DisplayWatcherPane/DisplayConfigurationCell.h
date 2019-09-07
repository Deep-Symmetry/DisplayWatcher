//
//  DisplayConfigurationCell.h
//  DisplayWatcherPane
//
//  Created by James Elliott on Sun Apr 11 2004.
//  Copyright © 2004-2019 Deep Symmetry, LLC. All rights reserved.
//

#import <AppKit/AppKit.h>


@interface DisplayConfigurationCell : NSCell {

}

- (id)init;

- (NSAffineTransform *)calculateTransformToFrame:(NSRect)cellFrame;

@end
