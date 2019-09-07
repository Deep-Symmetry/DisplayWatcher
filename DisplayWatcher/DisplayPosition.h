//
//  DisplayPosition.h
//  DisplayWatcher
//
//  Created by James Elliott on Sat Apr 10 2004.
//  Copyright © 2004-2019, Deep Symmetry, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DisplayPosition : NSObject <NSCoding> {
	NSRect frame;
}

- (id) initWithFrame:(NSRect)aFrame;

- (NSRect) frame;

- (BOOL) matches:(NSRect)aFrame withTolerance:(float)aTolerance;

@end
