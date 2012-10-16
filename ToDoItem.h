#import <Cocoa/Cocoa.h>

@interface ToDoItem : NSObject {
	
	NSString *package;
	NSString *time;
	NSNumber *priority;	
}

@property (retain) NSString *package;
@property (retain) NSString *time;
@property (retain) NSNumber *priority;


@end