//
//  HMCameraButtomView.m
//  KCD
//
//  Created by Hori,Masaki on 2016/03/20.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMCameraButtomView.h"

@interface HMCameraButtomView ()

@property (weak) IBOutlet NSButton *button;

@property (strong) NSTrackingArea *trackingArea;

@property NSRect hideRect;
@property NSRect showRect;

@end

@implementation HMCameraButtomView

- (instancetype)init
{
	self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
	
	return self;
}


- (void)awakeFromNib
{
	NSRect viewRect = self.view.frame;
	NSRect buttonRect = self.button.bounds;
	
	buttonRect.origin.x = 0.0;
	buttonRect.origin.y = viewRect.size.height;
	self.button.frame = buttonRect;
	
	[self.view addSubview:self.button];
	
	NSRect trackRect = buttonRect;
//	trackRect.origin.x -= trackRect.size.width;
	trackRect.origin.y -= trackRect.size.height;
	
	self.trackingArea = [[NSTrackingArea alloc] initWithRect:trackRect
													 options:NSTrackingMouseEnteredAndExited | NSTrackingActiveInActiveApp
													   owner:self
													userInfo:nil];
	
	[self.view addTrackingArea:self.trackingArea];
	
	self.hideRect = buttonRect;
	self.showRect = trackRect;
}

- (void)mouseEntered:(NSEvent *)theEvent
{
	self.button.animator.frame = self.showRect;
}

- (void)mouseExited:(NSEvent *)theEvent
{
	self.button.animator.frame = self.hideRect;
}

@end
