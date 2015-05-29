//
//  HMBookmarkItem.m
//  KCD
//
//  Created by Hori,Masaki on 2015/05/25.
//  Copyright (c) 2015年 Hori,Masaki. All rights reserved.
//

#import "HMBookmarkItem.h"

static NSString *HMBMIdentifireKey = @"HMBMIdentifireKey";
static NSString *HMBMNameKey = @"HMBMNameKey";
static NSString *HMBMURLStringKey = @"HMBMURLStringKey";
static NSString *HMBMWindowContentSizeKey = @"HMBMWindowContentSizeKey";
static NSString *HMBMContentVisibleRectKey = @"HMBMContentVisibleRectKey";
static NSString *HMBMCanResizeKey = @"HMBMCanResizeKey";
static NSString *HMBMCanScrollKey = @"HMBMCanScrollKey";
static NSString *HMBMScrollDelay = @"HMBMScrollDelay";

@implementation HMBookmarkItem

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.identifier forKey:HMBMIdentifireKey];
	[aCoder encodeObject:self.name forKey:HMBMNameKey];
	[aCoder encodeObject:self.urlString forKey:HMBMURLStringKey];
	[aCoder encodeSize:self.windowContentSize forKey:HMBMWindowContentSizeKey];
	[aCoder encodeRect:self.contentVisibleRect forKey:HMBMContentVisibleRectKey];
	[aCoder encodeBool:self.canResize forKey:HMBMCanResizeKey];
	[aCoder encodeBool:self.canScroll forKey:HMBMCanScrollKey];
	[aCoder encodeDouble:self.scrollDelay forKey:HMBMScrollDelay];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if(self) {
		_identifier = [aDecoder decodeObjectForKey:HMBMIdentifireKey];
		_name = [aDecoder decodeObjectForKey:HMBMNameKey];
		_urlString = [aDecoder decodeObjectForKey:HMBMURLStringKey];
		_windowContentSize = [aDecoder decodeSizeForKey:HMBMWindowContentSizeKey];
		_contentVisibleRect = [aDecoder decodeRectForKey:HMBMContentVisibleRectKey];
		_canResize = [aDecoder decodeBoolForKey:HMBMCanResizeKey];
		_canScroll = [aDecoder decodeBoolForKey:HMBMCanScrollKey];
		_scrollDelay = [aDecoder decodeDoubleForKey:HMBMScrollDelay];
	}
	return self;
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
			@"scrollDelay -> %lf}",
			self.identifier,
			self.name,
			self.urlString,
			NSStringFromSize(self.windowContentSize),
			NSStringFromRect(self.contentVisibleRect),
			self.canResize ? @"YES" : @"NO",
			self.canScroll ? @"YES" : @"NO",
			self.scrollDelay];
}

@end
