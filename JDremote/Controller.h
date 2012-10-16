//
//  Controller.h
//  JDremote
//
//  Created by Matthias Wagner on 29.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Controller : NSObject
{
	IBOutlet NSArrayController *doToItemsArrayController;

	IBOutlet NSTabView *TabView;
	
	IBOutlet NSTextField *TextField;
	IBOutlet NSLevelIndicator *SpeedIndicator;
	IBOutlet NSTextField *SpeedLabel;
	IBOutlet NSTextField *SpeedLimitLabel;
	IBOutlet NSSlider *LimitSlider;
	
	IBOutlet NSTextField *DLCfield;
	IBOutlet NSProgressIndicator *DLCupIndicator;

	IBOutlet NSSegmentedControl *StartStoppButton;
	
	IBOutlet NSTextField *DownloadPackageNameLabel;
	IBOutlet NSTextField *DownloadPackageNameChangeLabel;
	IBOutlet NSTextField *DownloadPackageNameField;
	
	IBOutlet NSProgressIndicator *LinkGrabberPackageChangeIndicator;

	

	
}

- (IBAction)Start:(id)sender;
- (IBAction)DeletePackage:(id)sender;
- (IBAction)XMLStart:(id)sender;

- (IBAction)SetSpeed:(id)sender;

- (IBAction)DLCsend:(id)sender;

- (IBAction)StartStopDownload:(id)sender;

- (IBAction)ChangeLinkGrabberPackageName:(id)sender;
- (IBAction)AddPackgageFromLinkGrabber:(id)sender;


- (IBAction)addNewToDoItem:(id)sender;





// *********              Unterprogramme         ***********  // 
- (NSString*)sendURL:(NSString*)string;
- (void)UpdateXML;
- (void)startTheBackgroundJob;
- (NSString*)ParseInfos:(NSString*)Response:(NSString*)From:(NSString*)To:(int)plus1:(int)plus2;
- (void)GetLinkGrabberData;




@end
