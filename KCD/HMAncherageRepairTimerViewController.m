//
//  HMAncherageRepairTimerViewController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/03/06.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAncherageRepairTimerViewController.h"

#import "HMAppDelegate.h"

#import "HMAnchorageRepairManager.h"

static const CGFloat regularHeight = 76;
static const CGFloat smallHeight = regularHeight - 32;

@interface HMAncherageRepairTimerViewController ()
@property (strong) HMAnchorageRepairManager *anchorageRepairManager;
@property (strong) NSNumber *repairTime;

@property (nonatomic, weak) IBOutlet NSButton *screenshotButton;
@property (strong) NSTrackingArea *trackingArea;

@end

@implementation HMAncherageRepairTimerViewController
@synthesize controlSize = _controlSize;

- (id)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	if(self) {
		_anchorageRepairManager = [HMAnchorageRepairManager defaultManager];
        _controlSize = NSControlSizeRegular;
		
		HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
		[appDelegate addCounterUpdateBlock:^{
			self.repairTime = [self calcRepairTime];
		}];
	}
	
	return self;
}

- (void)awakeFromNib
{
    [self refleshTrackingArea];
}

- (void)refleshTrackingArea
{
    for(NSTrackingArea *area in self.view.trackingAreas) {
        [self.view removeTrackingArea:area];
    }
    NSRect frame = self.screenshotButton.frame;
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:frame
                                                     options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp
                                                       owner:self
                                                    userInfo:nil];
    [self.view addTrackingArea:self.trackingArea];
}
- (void)mouseEntered:(NSEvent *)theEvent
{
	self.screenshotButton.image = [NSImage imageNamed:@"Camera"];
}
- (void)mouseExited:(NSEvent *)theEvent
{
	self.screenshotButton.image = [NSImage imageNamed:@"CameraDisabled"];
}

- (void)setControlSize:(NSControlSize)controlSize
{
    if(_controlSize == controlSize) return;
    
    NSRect frame = self.view.frame;
    frame.size.height = controlSize == NSControlSizeRegular ? regularHeight : smallHeight;
    self.view.frame = frame;
    
    NSRect buttonFrame = self.screenshotButton.frame;
    buttonFrame.size.width += controlSize == NSControlSizeRegular ? +32 : -32;
    self.screenshotButton.frame = buttonFrame;
    _controlSize = controlSize;
    
    [self refleshTrackingArea];
}
- (NSControlSize)controlSize
{
    return _controlSize;
}

+ (CGFloat)regularHeight
{
    return regularHeight;
}
+ (CGFloat)smallHeight
{
    return smallHeight;
}

- (NSNumber *)calcRepairTime
{
	NSDate *compTimeValue = self.anchorageRepairManager.repairTime;
	if(!compTimeValue) return nil;
	
	NSTimeInterval compTime = [compTimeValue timeIntervalSince1970];
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSTimeInterval diff = compTime - [now timeIntervalSince1970];
	return @(diff + 20 * 60);
}
@end
