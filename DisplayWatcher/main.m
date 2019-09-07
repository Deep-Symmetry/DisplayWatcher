//
//  main.m
//  DisplayWatcher
//
//  Created by Jim Elliott on Sat Apr 10 2004.
//  Copyright (c) 2004 Brunch Boy Design. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <mach/mach_port.h>
#import <mach/mach_interface.h>
#import <mach/mach_init.h>

#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>


#pragma mark Initialization

int main(int argc, const char *argv[])
{
	return NSApplicationMain(argc, argv);
}
