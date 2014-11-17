//
//  HMScreenshotInformation.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/09.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotInformation.h"

#import <Quartz/Quartz.h>


static NSDateFormatter *formatter = nil;

@implementation HMScreenshotInformation
+ (void)initialize
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSDateFormatter new];
		formatter.dateStyle = NSDateFormatterShortStyle;
		formatter.timeStyle = NSDateFormatterShortStyle;
		formatter.doesRelativeDateFormatting = YES;
	});
}
- (NSString *)imageUID
{
	return self.path;
}
- (NSString *)imageRepresentationType
{
	return IKImageBrowserQuickLookPathRepresentationType;
}
- (id)imageRepresentation
{
	return self.path;
}
- (NSString *)imageTitle
{
	return self.path.lastPathComponent.stringByDeletingPathExtension;
}
- (NSString *)imageSubtitle
{
	if(!self.creationDate) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSDictionary *fileAttr = [fm attributesOfItemAtPath:self.path error:NULL];
		self.creationDate = [fileAttr fileCreationDate];
	}
	return [formatter stringFromDate:self.creationDate];
}

- (NSUInteger)hash
{
	return [self.path hash];
}
- (BOOL)isEqual:(id)object
{
	return [self.path isEqual:object];
}

@end
