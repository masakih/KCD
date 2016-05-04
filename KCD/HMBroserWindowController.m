//
//  HMBroserWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/02/11.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMBroserWindowController.h"

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"
#import "HMDocksViewController.h"
#import "HMShipViewController.h"
#import "HMPowerUpSupportViewController.h"
#import "HMStrengthenListViewController.h"
#import "HMGameViewController.h"
#import "HMCombileViewController.h"
#import "HMCombinedCommand.h"
#import "HMFleetViewController.h"
#import "HMResourceViewController.h"
#import "HMRepairListViewController.h"
#import "HMAncherageRepairTimerViewController.h"


#import "HMServerDataStore.h"


typedef NS_ENUM(NSInteger, ViewType) {
	kScheduleType = 0,
	kOrganizeType = 1,
	kPowerUpType = 2,
	kRepairListType = 3,
};

typedef NS_ENUM(NSUInteger, FleetViewPosition) {
	kAbove,
	kBelow,
	kDivided,
	
	kOldStyle = 0xffffffff,
};

@interface HMBroserWindowController ()
@property (strong) HMGameViewController *gameViewController;

@property (weak) IBOutlet NSView *resourcePlaceholder;
@property (strong) HMResourceViewController *resourceViewController;

@property (weak) IBOutlet NSView *ancherageRepariTimerPlaceholder;
@property (strong) HMAncherageRepairTimerViewController *ancherageRepariTimerViewController;

@property (strong) NSNumber *flagShipID;

@property (strong) HMFleetViewController *fleetViewController;
@property FleetViewPosition fleetViewPosition;

@property (weak) IBOutlet NSTabView *informations;
@property (strong) HMDocksViewController *docksViewController;
@property (strong) HMShipViewController *shipViewController;
@property (strong) HMPowerUpSupportViewController *powerUpViewController;
@property (strong) HMStrengthenListViewController *strengthedListViewController;
@property (strong) HMRepairListViewController *repairListViewController;


@property (strong) HMCombileViewController *combinedViewController;
@property BOOL isCombinedMode;

@end

@implementation HMBroserWindowController
@synthesize fleetViewPosition = _fleetViewPosition;

+ (NSSet *)keyPathsForValuesAffectingFlagShipName
{
	return [NSSet setWithObject:@"flagShipID"];
}

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		[self loadWindow];
	}
	return self;
}

- (void)awakeFromNib
{
	self.gameViewController = [HMGameViewController new];
	[self.gameViewController.view setFrame:[self.placeholder frame]];
	[self.gameViewController.view setFrameOrigin:NSZeroPoint];
	[self.gameViewController.view setAutoresizingMask:[self.placeholder autoresizingMask]];
	[self.placeholder addSubview:self.gameViewController.view];
	
	self.resourceViewController = [HMResourceViewController new];
	[self.resourceViewController.view setFrameOrigin:NSZeroPoint];
	[self.resourcePlaceholder addSubview:self.resourceViewController.view];
	
	self.ancherageRepariTimerViewController = [HMAncherageRepairTimerViewController new];
	[self.ancherageRepariTimerViewController.view setFrameOrigin:NSZeroPoint];
	[self.ancherageRepariTimerPlaceholder addSubview:self.ancherageRepariTimerViewController.view];
	
	self.docksViewController = [HMDocksViewController new];
	self.shipViewController = [HMShipViewController new];
	self.powerUpViewController = [HMPowerUpSupportViewController new];
	self.strengthedListViewController = [HMStrengthenListViewController new];
	self.repairListViewController = [HMRepairListViewController new];
	NSTabViewItem *item = [self.informations tabViewItemAtIndex:0];
	item.view = self.docksViewController.view;
	item = [self.informations tabViewItemAtIndex:1];
	item.view = self.shipViewController.view;
	item = [self.informations tabViewItemAtIndex:2];
	item.view = self.powerUpViewController.view;
	item = [self.informations tabViewItemAtIndex:3];
	item.view = self.strengthedListViewController.view;
	item = [self.informations tabViewItemAtIndex:4];
	item.view = self.repairListViewController.view;
	
	_fleetViewController = [HMFleetViewController viewControlerWithViewType:detailViewType];
	[self.fleetViewController.view setFrame:[self.deckPlaceholder frame]];
	[self.fleetViewController.view setAutoresizingMask:[self.deckPlaceholder autoresizingMask]];
	[[self.deckPlaceholder superview] replaceSubview:self.deckPlaceholder with:self.fleetViewController.view];
	_fleetViewPosition = kBelow;
	[self setFleetViewPosition:HMStandardDefaults.fleetViewPosition animation:NO];
	self.fleetViewController.enableAnimation = NO;
	self.fleetViewController.shipOrder = HMStandardDefaults.fleetViewShipOrder;
	self.fleetViewController.enableAnimation = YES;
	
	[self bind:@"flagShipID" toObject:self.deckContoller withKeyPath:@"selection.ship_0" options:nil];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self
		   selector:@selector(didCangeCombined:)
			   name:HMCombinedCommandCombinedDidCangeNotification
			 object:nil];
	
	if(HMStandardDefaults.lastHasCombinedView) {
		[self showCombinedView];
	}
}

- (void)windowWillClose:(id)notification
{
	HMStandardDefaults.lastHasCombinedView = self.isCombinedMode;
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [HMServerDataStore defaultManager].managedObjectContext;
}

- (void)showViewWithNumber:(ViewType)type
{
	[self.informations selectTabViewItemAtIndex:type];
}

- (IBAction)reloadContent:(id)sender
{
	[self.gameViewController reloadContent:sender];
}

- (IBAction)deleteCacheAndReload:(id)sender
{
	[self.gameViewController deleteCacheAndReload:sender];
}

- (IBAction)clearQuestList:(id)sender
{
	HMServerDataStore *store = [HMServerDataStore oneTimeEditor];
	NSArray *objects = [store objectsWithEntityName:@"Quest"
										  predicate:nil
											  error:NULL];
	NSManagedObjectContext *moc = store.managedObjectContext;
	for(id object in objects) {
		[moc deleteObject:object];
	}
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
	[self showViewWithNumber:[sender tag]];
}
- (IBAction)screenShot:(id)sender
{
	[self.gameViewController screenShot:sender];
}

- (void)swipeWithEvent:(NSEvent *)event
{
	if(!HMStandardDefaults.useSwipeChangeCombinedView) return;
	
	if([event deltaX] > 0) {
		[self showCombinedView];
	}
	if([event deltaX] < 0) {
		[self hideCombinedView];
	}
}

#pragma mark - Combined view
- (IBAction)showHideCombinedView:(id)sender
{
	if(self.isCombinedMode) {
		[self hideCombinedView];
	} else {
		[self showCombinedView];
	}
}
- (void)showCombinedView
{
	if(self.isCombinedMode) return;
	if(self.fleetViewPosition == kOldStyle) return;
	
	self.isCombinedMode = YES;
	
	if(!self.combinedViewController) {
		self.combinedViewController = [HMCombileViewController new];
		self.combinedViewController.view.hidden = YES;
		
		[self.combinedViewController.view setAutoresizingMask:[self.combinedViewPlaceholder autoresizingMask]];
		[[self.combinedViewPlaceholder superview] replaceSubview:self.combinedViewPlaceholder with:self.combinedViewController.view];
	}
	
	NSRect winFrame = self.window.frame;
	CGFloat incrementWidth = NSMaxX(self.combinedViewController.view.frame);
	winFrame.size.width += incrementWidth;
	winFrame.origin.x -= incrementWidth;
	
	self.combinedViewController.view.hidden = NO;
	[self.window setFrame:winFrame display:YES animate:YES];
}
- (void)hideCombinedView
{
	if(!self.isCombinedMode) return;
	self.isCombinedMode = NO;
	
	NSRect winFrame = self.window.frame;
	CGFloat incrementWidth = NSMaxX(self.combinedViewController.view.frame);
	winFrame.size.width -= incrementWidth;
	winFrame.origin.x += incrementWidth;
	
	[self.window setFrame:winFrame display:YES animate:YES];
	self.combinedViewController.view.hidden = YES;
}

- (void)didCangeCombined:(id)notification
{
	if(!HMStandardDefaults.autoCombinedView) return;
	
	NSDictionary *info = [notification userInfo];
	NSNumber *typeValue = info[HMCombinedType];
	CombineType type = typeValue.integerValue;
	if(![NSThread isMainThread]) {
		[NSThread sleepForTimeInterval:0.1];
	}
	dispatch_async(dispatch_get_main_queue(),
				   ^{
					   switch(type) {
						   case cancel:
							   [self hideCombinedView];
							   break;
						   case maneuver:
						   case water:
						   case transportation:
							   [self showCombinedView];
							   break;
						   default:
							   NSLog(@"combined type is unknown type. %ld", type);
							   [self showCombinedView];
							   break;
					   }
				   });
}

#pragma mark - FleetView position
// ###############################
const CGFloat margin = 1;
const CGFloat flashTopMargin = 4;
// ###############################


- (void)changeFleetViewForFleetViewPositionIfNeeded:(FleetViewPosition)fleetViewPosition
{
	if(self.fleetViewPosition == fleetViewPosition) return;
	if(self.fleetViewPosition != kOldStyle && fleetViewPosition != kOldStyle) return;
	
	if(fleetViewPosition == kOldStyle && self.isCombinedMode) {
		[self hideCombinedView];
	}
	
	HMFleetViewType type = fleetViewPosition == kOldStyle ? minimumViewType : detailViewType;
	
	HMFleetViewController *newController = [HMFleetViewController viewControlerWithViewType:type];
	newController.enableAnimation = YES;
	newController.shipOrder = self.fleetViewController.shipOrder;
	
	NSView *currentView = self.fleetViewController.view;
	NSRect newFrame = newController.view.frame;
	newFrame.origin = currentView.frame.origin;
	newController.view.frame = newFrame;
	newController.view.autoresizingMask = currentView.autoresizingMask;
	[currentView.superview replaceSubview:currentView with:newController.view];
	
	self.fleetViewController = newController;
}

- (CGFloat)windowHeightForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	CGFloat windowContentHeight = [self.window.contentView frame].size.height;
	
	if(self.fleetViewPosition == fleetViewPosition) return windowContentHeight;
	
	if(self.fleetViewPosition == kOldStyle) {
		windowContentHeight += HMFleetViewController.heightDifference;
	}
	if(fleetViewPosition == kOldStyle) {
		windowContentHeight -= HMFleetViewController.heightDifference;
	}
	
	return windowContentHeight;
}
- (NSRect)windowFrameForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	NSRect windowContentRect = [self.window frame];
	
	if(self.fleetViewPosition == fleetViewPosition) return windowContentRect;
	
	if(self.fleetViewPosition == kOldStyle) {
		windowContentRect.size.height += HMFleetViewController.heightDifference;
		windowContentRect.origin.y -= HMFleetViewController.heightDifference;
	}
	if(fleetViewPosition == kOldStyle) {
		windowContentRect.size.height -= HMFleetViewController.heightDifference;
		windowContentRect.origin.y += HMFleetViewController.heightDifference;
	}
	
	return windowContentRect;
}

- (NSRect)flashFrameForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	CGFloat flashY;
	
	CGFloat windowContentHeight = [self windowHeightForFleetViewPosition:fleetViewPosition];
	NSRect flashRect = self.placeholder.frame;
	
	switch(fleetViewPosition) {
		case kAbove:
			flashY = windowContentHeight - flashRect.size.height - self.fleetViewController.normalHeight;
			break;
		case kBelow:
			flashY = windowContentHeight - flashRect.size.height;
			break;
		case kDivided:
			flashY = windowContentHeight - flashRect.size.height - self.fleetViewController.upsideHeight - margin;
			break;
		case kOldStyle:
			flashY = windowContentHeight - flashRect.size.height - flashTopMargin;
			break;
		default:
			NSLog(@"%s: unknown position.", __PRETTY_FUNCTION__);
			return NSZeroRect;
	}
	
	flashRect.origin.y = flashY;
	return flashRect;
}

- (NSRect)fleetViewFrameForFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	CGFloat fleetViewHeight;
	CGFloat fleetViewY;
	
	CGFloat windowContentHeight = [self windowHeightForFleetViewPosition:fleetViewPosition];
	NSRect flashRect = self.placeholder.frame;
	NSRect fleetListRect = self.fleetViewController.view.frame;
	
	switch(fleetViewPosition) {
		case kAbove:
			fleetViewHeight = self.fleetViewController.normalHeight;
			fleetViewY = windowContentHeight - fleetViewHeight;
			break;
		case kBelow:
			fleetViewHeight = self.fleetViewController.normalHeight;
			fleetViewY = windowContentHeight - fleetViewHeight - flashRect.size.height - margin;
			break;
		case kDivided:
			fleetViewHeight = self.fleetViewController.normalHeight + flashRect.size.height + margin + margin;
			fleetViewY = windowContentHeight - fleetViewHeight;
			break;
		case kOldStyle:
			fleetViewHeight = HMFleetViewController.oldStyleFleetViewHeight;
			fleetViewY = windowContentHeight - fleetViewHeight - flashRect.size.height - margin - flashTopMargin;
			break;
		default:
			NSLog(@"%s: unknown position.", __PRETTY_FUNCTION__);
			return NSZeroRect;
	}
	
	fleetListRect.size.height = fleetViewHeight;
	fleetListRect.origin.y = fleetViewY;
	return fleetListRect;
}

- (void)setFleetViewPosition:(FleetViewPosition)fleetViewPosition animation:(BOOL)flag
{
	[self changeFleetViewForFleetViewPositionIfNeeded:fleetViewPosition];
	
	NSRect windowFrame = [self windowFrameForFleetViewPosition:fleetViewPosition];
	NSRect flashRect = [self flashFrameForFleetViewPosition:fleetViewPosition];
	NSRect fleetListRect = [self fleetViewFrameForFleetViewPosition:fleetViewPosition];
	
	_fleetViewPosition = fleetViewPosition;
	HMStandardDefaults.fleetViewPosition = fleetViewPosition;
	
	if(flag) {
		NSDictionary *winAnime = @{
								   NSViewAnimationTargetKey : self.window,
								   NSViewAnimationEndFrameKey : [NSValue valueWithRect:windowFrame],
								   };
		NSDictionary *flashAnime = @{
						   NSViewAnimationTargetKey : self.placeholder,
						   NSViewAnimationEndFrameKey : [NSValue valueWithRect:flashRect],
						   };
		NSDictionary *fleetAnime = @{
								 NSViewAnimationTargetKey : self.fleetViewController.view,
								 NSViewAnimationEndFrameKey : [NSValue valueWithRect:fleetListRect],
								 };
		NSAnimation *anime = [[NSViewAnimation alloc] initWithViewAnimations:@[winAnime, flashAnime, fleetAnime]];
		[anime startAnimation];
	} else {
		[self.window setFrame:windowFrame display:NO];
		self.placeholder.frame = flashRect;
		self.fleetViewController.view.frame = fleetListRect;
	}
}

- (void)setFleetViewPosition:(FleetViewPosition)fleetViewPosition
{
	[self setFleetViewPosition:fleetViewPosition animation:YES];
}
- (FleetViewPosition)fleetViewPosition
{
	return _fleetViewPosition;
}
- (IBAction)fleetListAbove:(id)sender
{
	self.fleetViewPosition = kAbove;
}
- (IBAction)fleetListBelow:(id)sender
{
	self.fleetViewPosition = kBelow;
}
- (IBAction)fleetListDivide:(id)sender
{
	self.fleetViewPosition = kDivided;
}
- (IBAction)fleetListSimple:(id)sender
{
	self.fleetViewPosition = kOldStyle;
}

- (IBAction)reorderToDoubleLine:(id)sender
{
	self.fleetViewController.shipOrder = doubleLine;
	HMStandardDefaults.fleetViewShipOrder = doubleLine;
}
- (IBAction)reorderToLeftToRight:(id)sender
{
	self.fleetViewController.shipOrder = leftToRight;
	HMStandardDefaults.fleetViewShipOrder = leftToRight;
}

- (IBAction)selectNextFleet:(id)sender
{
	[_fleetViewController selectNextFleet:sender];
}
- (IBAction)selectPreviousFleet:(id)sender
{
	[_fleetViewController selectPreviousFleet:sender];
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	SEL action = menuItem.action;
	
	if(action == @selector(reloadContent:) || action == @selector(screenShot:) || action == @selector(deleteCacheAndReload:)) {
		return [self.gameViewController validateMenuItem:menuItem];
	}
	if(action == @selector(selectView:)) {
		return YES;
	}
	if(action == @selector(selectNextFleet:) || action == @selector(selectPreviousFleet:)) {
		return YES;
	}
	
	if(action == @selector(fleetListAbove:)) {
		if(self.fleetViewPosition == kAbove) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(fleetListBelow:)) {
		if(self.fleetViewPosition == kBelow) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(fleetListDivide:)) {
		if(self.fleetViewPosition == kDivided) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(fleetListSimple:)) {
		if(self.fleetViewPosition == kOldStyle) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	
	if(action == @selector(reorderToDoubleLine:)) {
		if(self.fleetViewController.shipOrder == doubleLine) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(reorderToLeftToRight:)) {
		if(self.fleetViewController.shipOrder == leftToRight) {
			menuItem.state = NSOnState;
		} else {
			menuItem.state = NSOffState;
		}
		return YES;
	}
	if(action == @selector(clearQuestList:)) {
		return YES;
	}
	if(action == @selector(showHideCombinedView:)) {
		if(self.isCombinedMode) {
			menuItem.title = NSLocalizedString(@"Hide Combined View", @"View menu, hide combined view");
		} else {
			menuItem.title = NSLocalizedString(@"Show Combined View", @"View menu, show combined view");
		}
		if(self.fleetViewPosition == kOldStyle) return NO;
		return YES;
	}
	
	return NO;
}

@end
