//
//  AppDelegate.h
//  JDremote
//
//  Created by Matthias Wagner on 29.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
@private
	NSWindow *window;

}
@property (assign) IBOutlet NSWindow *window;

@end
