//
//  HMBookmarkItem.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/25.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkItem.h"

@interface HMBookmarkItem ()
@property (strong, nonatomic) NSString *windowContentSizeString;
@property (strong, nonatomic) NSString *contentVisibleRectString;
@property (strong, nonatomic) NSNumber *scrollDelayValue;
@end

@implementation HMBookmarkItem

@dynamic identifier;
@dynamic name;
@dynamic urlString;
@dynamic canScroll;
@dynamic canResize;
@dynamic windowContentSizeString;
@dynamic contentVisibleRectString;
@dynamic order;
@dynamic scrollDelayValue;


- (void)setWindowContentSize:(NSSize)windowContentSize
{
	self.windowContentSizeString = NSStringFromSize(windowContentSize);
}
- (NSSize)windowContentSize
{
	return NSSizeFromString(self.windowContentSizeString);
}
- (void)setContentVisibleRect:(NSRect)contentVisibleRect
{
	self.contentVisibleRectString = NSStringFromRect(contentVisibleRect);
}
- (NSRect)contentVisibleRect
{
	return NSRectFromString(self.contentVisibleRectString);
}
- (void)setScrollDelay:(NSTimeInterval)scrollDelay
{
	self.scrollDelayValue = [NSNumber numberWithDouble:scrollDelay];
}
- (NSTimeInterval)scrollDelay
{
	return self.scrollDelayValue.doubleValue;
}


- (id)description
{
	return [NSString stringWithFormat:
			@"{identifier -> %@,\n"
			@"name -> %@,\n"
			@"urlString -> %@,\n"
			@"windowContentSize -> %@,\n"
			@"contentVisibleRect -> %@,\n"
			@"canResize -> %@,\n"
			@"canScroll -> %@,\n"
			@"scrollDelay -> %lf,\n"
			@"order -> %@}",
			self.identifier,
			self.name,
			self.urlString,
			NSStringFromSize(self.windowContentSize),
			NSStringFromRect(self.contentVisibleRect),
			self.canResize ? @"YES" : @"NO",
			self.canScroll ? @"YES" : @"NO",
			self.scrollDelay,
			self.order];
}

@end
