//
//  HMScreenshotListWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotListWindowController.h"

#import "HMScreenshotListViewController.h"
#import "HMScreenshotDetailViewController.h"
#import "HMScreenshotEditorViewController.h"

#import "HMScreenshotModel.h"


typedef BOOL (^HMFindViewController)(NSViewController *viewController);


@interface HMScreenshotListWindowController () <NSSplitViewDelegate, NSSharingServicePickerTouchBarItemDelegate>
@property (nonatomic, weak) NSPredicate *filterPredicate;
@property (nonatomic, weak) IBOutlet NSButton *shareButton;

@property (nonatomic, weak) IBOutlet NSView *left;
@property (nonatomic, weak) IBOutlet NSView *right;

@property (nonatomic, weak) IBOutlet NSViewController *rightController;

@property (nonatomic, strong) HMScreenshotListViewController *listViewController;
@property (nonatomic, strong) HMScreenshotDetailViewController *detailViewController;
@property (nonatomic, strong) HMScreenshotEditorViewController *editorViewController;

@property (strong) NSMutableArray<NSViewController *> *viewControllers;
@property (nonatomic, weak) HMBridgeViewController *currentRightViewController;

@end

@implementation HMScreenshotListWindowController
@synthesize filterPredicate = _filterPredicate;


+ (instancetype)new
{
    HMScreenshotListWindowController *result = [[self alloc] initWithWindowNibName:NSStringFromClass([self class])];
    [result window];
    return result;
}

- (void)replaceView:(NSView *)placeholder withViewController:(NSViewController *)viewController
{
    [viewController.view setFrame:[placeholder frame]];
    [viewController.view setFrameOrigin:NSZeroPoint];
    [viewController.view setAutoresizingMask:[placeholder autoresizingMask]];
    [placeholder addSubview:viewController.view];
}

- (void)windowDidLoad
{
    _viewControllers = [NSMutableArray array];
    
    [super windowDidLoad];
    
    self.listViewController = [HMScreenshotListViewController new];
    [self.viewControllers addObject:self.listViewController];
    [self replaceView:self.left withViewController:self.listViewController];
    self.listViewController.representedObject = self.listViewController.screenshots;
    
    self.detailViewController = [HMScreenshotDetailViewController new];
    [self.viewControllers addObject:self.detailViewController];
    [self.rightController addChildViewController:self.detailViewController];
    [self replaceView:self.right withViewController:self.detailViewController];
    self.detailViewController.representedObject = self.listViewController.screenshots;
    
    self.currentRightViewController = self.detailViewController;
    
    [self.shareButton sendActionOn:NSLeftMouseDownMask];
}

- (void)setFilterPredicate:(NSPredicate *)filterPredicate
{
	self.listViewController.screenshots.filterPredicate = filterPredicate;
	_filterPredicate = filterPredicate;
}
- (NSPredicate *)filterPredicate
{
	return _filterPredicate;
}

- (NSViewController *)findFromViewControllerUsingBlock:(HMFindViewController)blocks
{
	for(NSViewController *vc in self.viewControllers) {
        if(blocks(vc)) return vc;
	}
	
    return nil;
}

- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect
{
    id viewControler = [self findFromViewControllerUsingBlock:^BOOL(NSViewController *viewController) {
                            return [viewController respondsToSelector:_cmd];
                        }];
    
    [viewControler registerScreenshot:image fromOnScreen:screenRect];
}

- (IBAction)share:(id)sender
{
    [self.currentRightViewController share:sender];
}

- (id <NSSharingServiceDelegate>)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker delegateForSharingService:(NSSharingService *)sharingService
{
    return self.currentRightViewController;
}
- (NSArray *)itemsForSharingServicePickerTouchBarItem:(NSSharingServicePickerTouchBarItem *)pickerTouchBarItem
{
    return [self.currentRightViewController itemsForSharingServicePickerTouchBarItem:pickerTouchBarItem];
}

- (IBAction)changeToEditor:(id)sender
{
    if(!self.editorViewController) {
        self.editorViewController = [HMScreenshotEditorViewController new];
        [self.rightController addChildViewController:self.editorViewController];
        [self.editorViewController view];
        self.editorViewController.representedObject = self.listViewController.screenshots;
    }
    
    [self.rightController transitionFromViewController:self.detailViewController
                                      toViewController:self.editorViewController
                                               options:NSViewControllerTransitionSlideLeft
                                     completionHandler:nil];
    
    self.currentRightViewController = self.editorViewController;
}
- (IBAction)changeToDetail:(id)sender
{
    [self.rightController transitionFromViewController:self.editorViewController
                                      toViewController:self.detailViewController
                                               options:NSViewControllerTransitionSlideRight
                                     completionHandler:nil];
    
    self.currentRightViewController = self.detailViewController;
}

- (NSTouchBar *)touchBar
{
    return self.listViewController.touchBar;
}
#pragma mark - NSSplitViewDelegate

const CGFloat leftMinWidth = 299;
const CGFloat rightMinWidth = 400;

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if(dividerIndex == 0) {
        return leftMinWidth;
    }
    return proposedMinimumPosition;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if(dividerIndex == 0) {
        NSSize size = splitView.frame.size;
        CGFloat rightWidth = size.width - proposedPosition;
        if(rightWidth < rightMinWidth) {
            return size.width - rightMinWidth;
        }
    }
    return proposedPosition;
}
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    [splitView adjustSubviews];
    
    NSView *leftView = splitView.subviews[0];
    NSView *rightView = splitView.subviews[1];
    
    if(NSWidth(leftView.frame) < leftMinWidth) {
        NSRect leftRect = leftView.frame;
        leftRect.size.width = leftMinWidth;
        leftView.frame = leftRect;
        
        NSRect rightRect = rightView.frame;
        rightRect.size.width = NSWidth(splitView.frame) - NSWidth(leftRect) - splitView.dividerThickness;
        rightRect.origin.x = NSWidth(leftRect) + splitView.dividerThickness;
        rightView.frame = rightRect;
    }
}
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    NSView *leftView = splitView.subviews[0];
    NSView *rightView = splitView.subviews[1];
    
    if(leftView == view) {
        if(NSWidth(leftView.frame) < leftMinWidth) return NO;
    }
    if(rightView == view) {
        if(NSWidth(leftView.frame) >= leftMinWidth) return NO;
    }
    
    return YES;
}


@end
