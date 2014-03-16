//
//  HMBroserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBroserWindowController.h"

#import "HMDocksViewController.h"
#import "HMShipViewController.h"
#import "HMPowerUpSupportViewController.h"

#import "HMCoreDataManager.h"


static NSString *prevReloadDateStringKey = @"previousReloadDateString";

typedef NS_ENUM(NSInteger, ViewType) {
	kScheduleType = 0,
	kOrganizeType = 1,
	kPowerUpType = 2,
};

@interface HMBroserWindowController ()

@property (strong) NSViewController *selectedViewController;
@property (strong) NSMutableDictionary *controllers;

@property (strong) NSNumber *flagShipID;

@end

@implementation HMBroserWindowController

+ (NSSet *)keyPathsForValuesAffectingFlagShipName
{
	return [NSSet setWithObject:@"flagShipID"];
}

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_controllers = [NSMutableDictionary new];
	}
	return self;
}

- (void)awakeFromNib
{
	
	NSClipView *clip = [[NSClipView alloc] initWithFrame:[self.placeholder frame]];
	[clip setAutoresizingMask:[self.placeholder autoresizingMask]];
	[[self.placeholder superview] replaceSubview:self.placeholder with:clip];
	[clip setDocumentView:self.webView];
	[clip scrollToPoint:NSMakePoint(70, 425)];
	
	self.selectedViewController = [HMDocksViewController new];
	[self.selectedViewController.view setFrame:[self.docksPlaceholder frame]];
	[self.selectedViewController.view setAutoresizingMask:[self.docksPlaceholder autoresizingMask]];
	[[self.docksPlaceholder superview] replaceSubview:self.docksPlaceholder with:self.selectedViewController.view];
	[self.controllers setObject:self.selectedViewController forKey:@0];
	
	
	[[[self.webView mainFrame] frameView] setAllowsScrolling:NO];
	
	[self.webView setApplicationNameForUserAgent:@"Version/6.0 Safari/536.25"];
	[self.webView setMainFrameURL:@"http://www.dmm.com/netgame/social/-/gadgets/=/app_id=854854/"];
	//	[self.webView setMainFrameURL:@"http://www.google.com/"];
	
	[self bind:@"flagShipID" toObject:self.deckContoller withKeyPath:@"selection.ship_0" options:nil];
}


- (NSManagedObjectContext *)managedObjectContext
{
	return [HMCoreDataManager defaultManager].managedObjectContext;
}

- (NSAttributedString *)linksString
{
	NSBundle *main = [NSBundle mainBundle];
	NSURL *url = [main URLForResource:@"Links" withExtension:@"rtf"];
	NSAttributedString *linksString = [[NSAttributedString alloc] initWithURL:url documentAttributes:nil];
	
	return linksString;
}

- (void)showViewWithNumber:(ViewType)type
{
	Class controllerClass = Nil;

	switch (type) {
		case kScheduleType:
			controllerClass = [HMDocksViewController class];
			break;
		case kOrganizeType:
			controllerClass = [HMShipViewController class];
			break;
		case kPowerUpType:
			controllerClass = [HMPowerUpSupportViewController class];
			break;
	}
	
	if(!controllerClass) return;
	if([self.selectedViewController isMemberOfClass:controllerClass]) return;
	
	NSViewController *newContoller = [self.controllers objectForKey:@(type)];
	if(!newContoller) {
		newContoller = [controllerClass new];
		[self.controllers setObject:newContoller forKey:@(type)];
	}
	[newContoller.view setFrame:[self.selectedViewController.view frame]];
	[newContoller.view setAutoresizingMask:[self.selectedViewController.view autoresizingMask]];
	[[self.selectedViewController.view superview] replaceSubview:self.selectedViewController.view with:newContoller.view];
	self.selectedViewController = newContoller;
	
	self.selectedViewsSegment = type;
}

- (IBAction)reloadContent:(id)sender
{
	id /*NSClipView * */ clip = [self.webView superview];
	[clip scrollToPoint:NSMakePoint(70, 425)];
	
	NSString *prevReloadDateString = [[NSUserDefaults standardUserDefaults] stringForKey:prevReloadDateStringKey];
	if(prevReloadDateString) {
		NSDate *prevDate = [NSDate dateWithString:prevReloadDateString];
		NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
		if([now timeIntervalSinceDate:prevDate] < 1 * 60) {
			NSDate *untilDate = [prevDate dateByAddingTimeInterval:1 * 60];
			NSString *date = [NSDateFormatter localizedStringFromDate:untilDate
															dateStyle:NSDateFormatterNoStyle
															timeStyle:NSDateFormatterMediumStyle];
			NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Reload interval is too short", @"")
											 defaultButton:nil
										   alternateButton:nil
											   otherButton:nil
								 informativeTextWithFormat:NSLocalizedString(@"Reload interval is too short.\nWait until %@.", @""), date];
			[alert runModal];
			
			return;
		}
	}
	
	[self.webView reload:sender];
	
	[[NSUserDefaults standardUserDefaults] setValue:[[NSDate dateWithTimeIntervalSinceNow:0] description]
											 forKey:prevReloadDateStringKey];
}

- (NSString *)flagShipName
{
	NSError *error = nil;
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Ship"];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", self.flagShipID];
	[request setPredicate:predicate];
	NSArray *array = [self.managedObjectContext executeFetchRequest:request
													 error:&error];
	if([array count] == 0) {
		return nil;
	}
	
	id flagShipName = [array[0] valueForKeyPath:@"master_ship.name"];
	if(!flagShipName || [flagShipName isKindOfClass:[NSNull class]]) {
		return nil;
	}
	
	return flagShipName;
}


- (IBAction)selectView:(id)sender
{
	NSInteger tag = -1;
	if([sender respondsToSelector:@selector(selectedSegment)]) {
		NSSegmentedCell *cell = [sender cell];
		NSUInteger index = [sender selectedSegment];
		tag = [cell tagForSegment:index];
	} else {
		tag = [sender tag];
	}
	[self showViewWithNumber:tag];
}

@end
