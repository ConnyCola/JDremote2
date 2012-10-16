//
//  Controller.m
//  JDremote
//
//  Created by Matthias Wagner on 29.09.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Controller.h"
#import "AppDelegate.h"
#import "ToDoItem.h"

NSString *URLget = @"http://broserver.dyndns-home.com:10025/get";
NSString *URLset = @"http://broserver.dyndns-home.com:10025/set";
NSString *URLaction = @"http://broserver.dyndns-home.com:10025/action";

NSString *LinkGrabberPackageName = @"";

NSString *Speed = @"";


NSMutableArray *PackageNameArray;


@implementation Controller


- (void)awakeFromNib
{
	
	NSString *Limit = [self sendURL:[URLget stringByAppendingString:@"/speedlimit"]];
	[SpeedLimitLabel setStringValue:Limit];
	[LimitSlider setIntegerValue:Limit.intValue];
	Speed = [self sendURL:[URLget stringByAppendingString:@"/speed"]]; 
	if (Speed.intValue == 0) 
		StartStoppButton.selectedSegment = 1;
	[SpeedIndicator setIntValue:Speed.intValue];
	[SpeedLabel setStringValue:[Speed stringByAppendingString:@" Kbps"]];
	
	[self GetLinkGrabberData];
	
	[self UpdateXML];

	[NSThread detachNewThreadSelector:@selector(startTheBackgroundJob) toTarget:self withObject:nil];  
}



- (void)startTheBackgroundJob 
{
	while (true) {
		Speed = [self sendURL:[URLget stringByAppendingString:@"/speed"]]; 
		[SpeedIndicator setIntValue:Speed.intValue];
		[SpeedLabel setStringValue:[Speed stringByAppendingString:@" Kb/s"]];
		sleep(1);
	}
}  





- (IBAction)Start:(id)sender
{
	//NSString *RES = [self sendURL:@"http://broserver.dyndns-home.com:10025/get/downloads/all/list"];
	//[TextField setStringValue:RES];

}



- (IBAction)XMLStart:(id)sender
{
	[self UpdateXML];
}


- (IBAction)SetSpeed:(id)sender
{	//    Slider     //  Aktiviert das Untergrogramm!
	
	NSString *Limit = [self sendURL:[[URLset stringByAppendingString:@"/download/limit/"]stringByAppendingString:[NSString stringWithFormat:@"%d", LimitSlider.intValue]]];
	Speed = [self sendURL:[URLget stringByAppendingString:@"/speed"]]; 
	[SpeedIndicator setIntValue:Speed.intValue];
	[SpeedLabel setStringValue:[Speed stringByAppendingString:@" Kb/s"]];
	
	[SpeedLimitLabel setStringValue:[NSString stringWithFormat:@"%i", LimitSlider.intValue]];
	[TextField setStringValue:Speed];
}



- (IBAction)DLCsend:(id)sender
{
	NSString *source = DLCfield.stringValue;
	DLCfield.stringValue = @"";
	
	NSString *destinationMAC = @"/Volumes/BroDrive2/DLC/file.dlc";
	NSString *destinationPC = @"I:\DLC/file.dlc";
	
	[[NSFileManager defaultManager] removeItemAtPath:destinationMAC error:nil];
	[[NSFileManager defaultManager] copyItemAtPath:source toPath:destinationMAC error:nil];
	
	NSString *URL = @"http://broserver.dyndns-home.com:10025/action/add/container/";
	[self sendURL:[URL stringByAppendingString:destinationPC]];
	
	
	[DLCupIndicator startAnimation:nil];
	while ([LinkGrabberPackageName isEqualToString:@""]) {
		sleep(2);
		[self GetLinkGrabberData];
	}
	[DLCupIndicator stopAnimation:nil];
	[TabView selectLastTabViewItem:nil];

}


- (IBAction)StartStopDownload:(id)sender
{	if(StartStoppButton.selectedSegment == 0) [self sendURL:[URLaction stringByAppendingString:@"/start"]];
	else									  [self sendURL:[URLaction stringByAppendingString:@"/stop"]]; 
}

- (IBAction)ChangeLinkGrabberPackageName:(id)sender
{	
	NSString *str = [URLaction stringByAppendingString:@"/grabber/rename/"];
	str = [str stringByAppendingString:LinkGrabberPackageName];
	str = [str stringByAppendingString:@"/"];
	str = [str stringByAppendingString:DownloadPackageNameField.stringValue];
	str = [str stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSLog(@"%@",str);
	[self sendURL:str];
	
	[LinkGrabberPackageChangeIndicator startAnimation:nil];	
	sleep(1);
	NSString *URL = [URLget stringByAppendingString:@"/grabber/list"];
	sleep(1);
	[LinkGrabberPackageChangeIndicator stopAnimation:nil];
	
	LinkGrabberPackageName = [self ParseInfos:[self sendURL:URL] :@"package_name" :@"file file_available" :2 :7];
	NSLog(@"LinkGrabberPackageName : %@",LinkGrabberPackageName);
	DownloadPackageNameChangeLabel.stringValue = LinkGrabberPackageName;
}

- (IBAction)AddPackgageFromLinkGrabber:(id)sender
{	[self sendURL:[URLaction stringByAppendingString:@"/grabber/confirmall"]];
	[self GetLinkGrabberData];
	DownloadPackageNameChangeLabel.stringValue = @"";
	DownloadPackageNameField.stringValue = @"";
	[self UpdateXML];
	[TabView selectFirstTabViewItem:nil];

}


- (IBAction)addNewToDoItem:(id)sender
{
    ToDoItem *newToDo = [[ToDoItem alloc] init];
	
	[newToDo setPriority:[NSNumber numberWithInt:80]];
    [newToDo setTime:@"Test Eintrag"];
    [newToDo setPackage:@"leer"];
	
    [doToItemsArrayController addObject:newToDo]; 
}


- (IBAction)DeletePackage:(id)sender
{
	int i = [doToItemsArrayController selectionIndex];
	NSLog(@"count : %d",i);
	
	
	NSString *PackageDelete = [PackageNameArray objectAtIndex:i];
	NSString *PackageDeleteURL = PackageDelete;
	NSLog(@"Es soll gelöscht werden: %@",PackageDelete);
	
	PackageDeleteURL = [PackageDelete stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	//Müssen noch umlaute eingefügt werden!!!
	NSString *URL = [URLaction stringByAppendingFormat:@"/downloads/remove/"];
	[self sendURL:[URL stringByAppendingFormat:PackageDeleteURL]];
	sleep(1);
	
	NSString *destinationMAC = @"/Volumes/BroDrive2/SORTIEREN/";
	destinationMAC = [destinationMAC stringByAppendingString:PackageDelete];
	[[NSFileManager defaultManager] removeItemAtPath:destinationMAC error:nil];

	[self UpdateXML];
	
}








//************************************************************//
// *********              Unterprogramme         ***********  // 
//************************************************************//


- (void)GetLinkGrabberData
{
	NSString *URL = [URLget stringByAppendingString:@"/grabber/list"];
	NSString *RES = @"";
	
		RES = [self sendURL:URL];
			LinkGrabberPackageName = [self ParseInfos:RES :@"package_name" :@"file file_available" :2 :7];
			NSLog(@"%@",LinkGrabberPackageName);
			DownloadPackageNameLabel.stringValue = LinkGrabberPackageName;

}

- (void)UpdateXML
{
	[doToItemsArrayController removeObjects:[doToItemsArrayController arrangedObjects]];

	
	NSString *RES = [self sendURL:@"http://broserver.dyndns-home.com:10025/get/downloads/all/list"];
	NSString *Backp = @"";
	NSString *BackPri = @"";
	NSString *BackTime = @"";
	PackageNameArray = [NSMutableArray new];
	

	Backp = @"0";
	int index = 0;
	
	while ([Backp isNotEqualTo:@""]) {
		
		if(index != 0)
		{
			NSRange match1, match2;
			match1 = [RES rangeOfString: @"/packages"];
			match2.location = 0;
			match2.length = match1.location + match1.length;
			RES = [RES stringByReplacingCharactersInRange:match2 withString:@""];
			
		}
		
		
		Backp =		[self ParseInfos: RES :@"package_name" :@"package_percent" :2 :4];
		BackPri =	[self ParseInfos: RES :@"package_percent" :@"package_size" :2 :4];
		BackTime =  [self ParseInfos: RES :@"package_todo" :@"file file_downloaded" :2 :7];
		NSLog(@"%@",BackTime);


		/*
		 if([BackTime isEqualToString:@"0 B"])
		 BackTime = @"";
		 else{
		 int intBacktime = ((BackTime.intValue * 17) / Speed.intValue);
		 NSLog(@"%d",intBacktime);
		 BackTime = [NSString stringWithFormat:@"%d",intBacktime];
		 }
		 */
		if ([Backp isNotEqualTo:@""]) {
			[PackageNameArray addObject:Backp];	
			index++;
			
			ToDoItem *newToDo = [[ToDoItem alloc] init];
			
			[newToDo setPackage:Backp];
			[newToDo setTime:BackTime];
			[newToDo setPriority:[NSNumber numberWithInt:BackPri.intValue]];
			
			[doToItemsArrayController addObject:newToDo]; 
		}
	
		
		
		// den File Stauts eines Packages durchsuchen um zu sehen ob alle Packete "Erledigt" sind
		NSString *RES2 = RES;
		NSString *RES3 = RES;

		NSRange match3;
		NSRange match4;
		
		int countFile = 0;
		int countErledigt = 0;
		
		match3 = [RES2 rangeOfString:@"/packages"];
		match3.length = RES2.length - match3.location;
		
		if (match3.location != NSNotFound) {
			RES2 = [RES2 stringByReplacingCharactersInRange:match3 withString:@""];
			RES3 = RES2;
			
			match3 = [RES2 rangeOfString:@"file_status"];
			match4 = [RES3 rangeOfString:@"Entpacken OK"];
			
			while (match3.location != NSNotFound) {
				countFile++;
				match3.length = match3.location + match3.length;
				match3.location = 0;
				
				RES2 = [RES2 stringByReplacingCharactersInRange:match3 withString:@""];
				match3 = [RES2 rangeOfString:@"file_status"];
			}
			
			while (match4.location != NSNotFound) {
				countErledigt++;
				match4.length = match4.location + match4.length;
				match4.location = 0;
				
				RES3 = [RES3 stringByReplacingCharactersInRange:match4 withString:@""];
				match4 = [RES3 rangeOfString:@"Entpacken OK"];
			}
			NSLog(@"///// %@",Backp);
			NSLog(@"   // Files found:    %d",countFile);
			NSLog(@"   // Erledigt found: %d",countErledigt);
		}

	}
}


- (NSString*)sendURL:(NSString*)string
{
	NSURL *url = [NSURL URLWithString:string];                                            
	NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url												cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData 
											timeoutInterval:30];                                 
	NSData *urlData;          
	NSURLResponse *response;  
	NSError *error;           
	
	urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
	if (!urlData) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert runModal];}
	
	return [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding]; 
}

- (NSString*)ParseInfos:(NSString*)Response:(NSString*)From:(NSString*)To:(int)plus1:(int)plus2
{
	NSString *MatchString;
	NSRange match1, match2;
	
	match1 = [Response rangeOfString: From];
	match2 = [Response rangeOfString: To];
	
	if (match1.length == 0)
		return @"";

	MatchString = [Response substringWithRange: NSMakeRange(match1.location+match1.length + plus1, match2.location - (match1.location+match1.length + plus2))];
	return MatchString;
}

@end
