//
//  DisplayWatcher.h
//  DisplayWatcher
//
//  Created by Jim Elliott on Sat Apr 10 2004.
//  Copyright (c) 2004 Brunch Boy Design. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DisplayWatcher : NSObject {

}

- (void)launchFileWithPath:(NSString *)path;
- (void)handleDisplayGeometryChange:(NSNotification *)note;
- (void)handleSleeping:(NSNotification *)note;
- (void)handleAwoke:(NSNotification *)note;

@end
