//
//  DisplayConfiguration.h
//  DisplayWatcher
//
//  Created by James Elliott on Sat Apr 10 2004.
//  Copyright © 2004-2019 Deep Symmetry, LLC. All rights reserved.
//
// Encapsulates the information needed to recognize a particular display configuration, as well
// as the path of the file to be opened when that configuration is detected.

#import <Foundation/Foundation.h>

#define X_KEY "DisplayX"
#define Y_KEY "DisplayY"
#define WIDTH_KEY "DisplayWidth"
#define HEIGHT_KEY "DisplayHeight"

@interface DisplayConfiguration : NSObject <NSCoding> {
	NSString *name;
	NSMutableArray *displays;
	float tolerance;
	NSString *fileToOpen;
}

- (void) recordCurrentConfiguration;
- (BOOL) matchesCurrentConfiguration;

- (NSString *) name;
- (void) setName:(NSString *)aName;

- (float) tolerance;
- (void) setTolerance:(float)aTolerance;

- (NSString *) fileToOpen;
- (void) setFileToOpen:(NSString *)aPath;

- (NSArray *)displays;

- (NSImage *) configImage;
- (NSImage *) fileImage;

@end
