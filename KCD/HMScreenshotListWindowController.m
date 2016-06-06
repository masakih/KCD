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
	return [storyboard instantiateInitialController];
}

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
	NSViewController *viewControler = [self findFromViewController:self.contentViewController
														usingBlock:^BOOL(NSViewController *viewController) {
															return [viewController respondsToSelector:_cmd];
														}];
	[viewControler performSelector:_cmd withObject:sender];
}

- (void)showViewControllerHierarchy:(NSViewController *)viewController level:(NSInteger)level
{
	if(!viewController) return;
	
	NSString *desc = [NSString stringWithFormat:@"<%p> %@", viewController, viewController];
	fprintf(stderr, "%*s%s\n", (int)level * 4, " ", desc.UTF8String);
	for(NSViewController *vc in viewController.childViewControllers) {
		[self showViewControllerHierarchy:vc level:level + 1];
	}
}

- (IBAction)showViewControllerHierarchy:(id)sender
{
	[self showViewControllerHierarchy:self.contentViewController level:0];
}
@end
