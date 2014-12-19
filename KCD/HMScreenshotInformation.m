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

@interface HMScreenshotInformation ()
@property (nonatomic, strong) NSURL *url;
@end

@implementation HMScreenshotInformation
@synthesize creationDate = _creationDate;
@synthesize url = _url;

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
	return [formatter stringFromDate:self.creationDate];
}
- (NSUInteger)imageVersion
{
	return self.version;
}

- (NSDate *)creationDate
{
	if(!_creationDate) {
		NSFileManager *fm = [NSFileManager defaultManager];
		NSDictionary *fileAttr = [fm attributesOfItemAtPath:self.path error:NULL];
		_creationDate = [fileAttr fileCreationDate];
	}
	return _creationDate;
}
- (void)setCreationDate:(NSDate *)creationDate
{
	_creationDate = creationDate;
}
- (NSURL *)url
{
	if(_url) return _url;
	_url = [NSURL fileURLWithPath:self.path];
	return _url;
}

- (NSArray *)tags
{
	NSError *error = nil;
	NSArray *tags;
	if(![self.url getResourceValue:&tags forKey:NSURLTagNamesKey error:&error]) {
		if(error) {
			NSLog(@"get tags error -> %@", error);
			return @[];
		}
	}
	return tags;
}
- (void)setTags:(NSArray *)tags
{
	NSError *error = nil;
	[self.url setResourceValue:tags forKey:NSURLTagNamesKey error:&error];
	if(error) {
		NSLog(@"set tags error -> %@", error);
	}
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
