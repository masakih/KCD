//
//  HMAASegue.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMSlideReplaceSegue.h"

@implementation HMSlideReplaceSegue
- (void)perform
{
	
	NSInteger slide  = 1;
	if([self.identifier isEqualToString:@"left"]) {
		slide = -1;
	}
	
	NSViewController *s = self.sourceController;
	NSViewController *d = self.destinationController;
	NSView *superView = s.view.superview;
	NSViewController *p = s.parentViewController;
	
	[p addChildViewController:d];
	
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
		NSRect sFrame = s.view.frame;
		NSRect dFrame = sFrame;
		dFrame.origin.x += slide * -dFrame.size.width;
		d.view.frame = dFrame;
		[superView addSubview:d.view];
		
		dFrame.origin.x = sFrame.origin.x;
		sFrame.origin.x += slide * sFrame.size.width;
		
		s.view.animator.frame = sFrame;
		d.view.animator.frame = dFrame;
		
		d.view.autoresizingMask = s.view.autoresizingMask;
		
	} completionHandler:^{
		[s removeFromParentViewController];
		[s.view removeFromSuperview];
	}];
}
@end
