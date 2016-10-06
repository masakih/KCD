//
//  HMScreenshotListWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotListWindowController.h"

#import "HMScreenshotListViewController.h"

#import "HMScreenshotModel.h"


typedef BOOL (^HMFindViewController)(NSViewController *viewController);


@interface HMScreenshotListWindowController ()
@property (nonatomic, weak) NSPredicate *filterPredicate;
@property (nonatomic, weak) IBOutlet NSButton *shareButton;
@end

@implementation HMScreenshotListWindowController
@synthesize filterPredicate = _filterPredicate;


+ (instancetype)new
{
	NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"HMScreenshotList" bundle:nil];
	HMScreenshotListWindowController *wc = [storyboard instantiateInitialController];
	wc.windowFrameAutosaveName = NSStringFromClass([self class]);
	return wc;
}

//- (void)windowWillLoad
//{
//	self.windowFrameAutosaveName = NSStringFromClass([self class]);
//}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[self.shareButton sendActionOn:NSLeftMouseDownMask];
}

- (void)setFilterPredicate:(NSPredicate *)filterPredicate
{
	id vc = self.contentViewController;
	assert([vc isKindOfClass:[HMScreenshotListViewController class]]);
	HMScreenshotListViewController *viewController = vc;
	
	viewController.screenshots.filterPredicate = filterPredicate;
	_filterPredicate = filterPredicate;
}
- (NSPredicate *)filterPredicate
{
	return _filterPredicate;
}

- (NSViewController *)findFromViewController:(NSViewController *)viewController usingBlock:(HMFindViewController)blocks
{
	if(blocks(viewController)) return viewController;
	
	for(NSViewController *vc in viewController.childViewControllers) {
		NSViewController *found = [self findFromViewController:vc usingBlock:blocks];
		if(found) {
			return found;
		}
	}
	
	return nil;
}

- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect
{
	id viewControler = [self findFromViewController:self.contentViewController
										 usingBlock:^BOOL(NSViewController *viewController) {
											 return [viewController respondsToSelector:_cmd];
										 }];
	
	[viewControler registerScreenshot:image fromOnScreen:screenRect];
}

- (IBAction)share:(id)sender
{
	id viewControler = [self findFromViewController:self.contentViewController
														usingBlock:^BOOL(NSViewController *viewController) {
															return [viewController respondsToSelector:_cmd];
														}];
	[viewControler share:sender];
}

@end
