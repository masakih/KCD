//
//  HMScreenshotWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotWindowController.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface HMScreenshotWindowController ()

@property (strong) NSImage *snap;

@property (strong) ACAccountStore *accountStore;
@property NSInteger shortURLLength;


- (void)postImage:(NSData *)jpeg withStatus:(NSString *)status;
@end

@implementation HMScreenshotWindowController
@synthesize snapData = _snapData;
@synthesize snap = _snap;
@synthesize appendKanColleTag = _appendKanColleTag;

+ (NSSet *)keyPathsForValuesAffectingLeaveLength
{
	return [NSSet setWithObjects:@"tweetString", @"appendKanColleTag", nil];
}
+ (NSSet *)keyPathsForValuesAffectingLeaveLengthColor
{
	return [NSSet setWithObject:@"leaveLength"];
}
+ (NSSet *)keyPathsForValuesAffectingSnap
{
	return [NSSet setWithObject:@"snapData"];
}

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_accountStore = [ACAccountStore new];
		
		[self checkShortURLLength];
#warning change this
		_tagString = @" #艦これ";
		_appendKanColleTag = [[NSUserDefaults standardUserDefaults] boolForKey:@"appendKanColleTag"];
	}
	return self;
}

- (NSData *)snapData
{
	return _snapData;
}
- (void)setSnapData:(NSData *)snapData
{
	_snapData = snapData;
	_snap = nil;
}

- (NSImage *)snap
{
	if(_snap) return _snap;
	
	NSImage *image = [[NSImage alloc] initWithData:self.snapData];
	_snap = image;
	self.tweetString = nil;
	
	return _snap;
}
- (void)setSnap:(NSImage *)snap
{
	_snap = snap;
}

- (NSInteger)leaveLength
{
	const NSUInteger maxTweetLength = 140;
	if(self.appendKanColleTag) return maxTweetLength - self.tagString.length - self.shortURLLength - self.tweetString.length;
	return maxTweetLength - self.shortURLLength - self.tweetString.length;
}
- (NSColor *)leaveLengthColor
{
	if(self.leaveLength < 0) {
		return [NSColor colorWithCalibratedRed:159/255.0 green:14/255.0 blue:0 alpha:1];
	}
	return [NSColor controlTextColor];
}
- (BOOL)appendKanColleTag
{
	return _appendKanColleTag;
}
- (void)setAppendKanColleTag:(BOOL)appendKanColleTag
{
	[[NSUserDefaults standardUserDefaults] setBool:appendKanColleTag forKey:@"appendKanColleTag"];
	_appendKanColleTag = appendKanColleTag;
}

- (IBAction)tweet:(id)sender
{
	if(!self.snap) {
		NSBeep();
		return;
	}
	
	NSString *status = self.tweetString;
	if(self.appendKanColleTag) {
		status = [status stringByAppendingString:self.tagString];
	}
	[self postImage:self.snapData withStatus:status];
	
	[self.window orderOut:nil];
}

- (IBAction)saveSnap:(id)sender
{
	[self.window orderOut:nil];
	//
	//
	
}
- (IBAction)cancel:(id)sender
{
	[self.window orderOut:nil];
}
- (void)postImage:(NSData *)jpeg withStatus:(NSString *)status
{
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	SLRequestHandler requestHandler =
	^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		if (responseData) {
			NSInteger statusCode = urlResponse.statusCode;
			if (statusCode >= 200 && statusCode < 300) {
				NSDictionary *postResponseData =
				[NSJSONSerialization JSONObjectWithData:responseData
												options:NSJSONReadingMutableContainers
												  error:NULL];
				NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
			}
			else {
				NSLog(@"[ERROR] Server responded: status code %ld %@", statusCode,
					  [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
			}
		}
		else {
			NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
		}
	};
	
	ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
	^(BOOL granted, NSError *error) {
		if (granted) {
			NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
			NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
						  @"/1.1/statuses/update_with_media.json"];
			NSDictionary *params = @{@"status" : status};
			SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
													requestMethod:SLRequestMethodPOST
															  URL:url
													   parameters:params];
			[request addMultipartData:jpeg
							 withName:@"media[]"
								 type:@"image/jpeg"
							 filename:@"image.jpg"];
			[request setAccount:[accounts lastObject]];
			[request performRequestWithHandler:requestHandler];
		}
		else {
			NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
				  [error localizedDescription]);
		}
	};
	
	[self.accountStore requestAccessToAccountsWithType:twitterType
											   options:NULL
											completion:accountStoreHandler];
}

- (void)checkShortURLLength
{
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	SLRequestHandler requestHandler =
	^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		if (responseData) {
			NSInteger statusCode = urlResponse.statusCode;
			if (statusCode >= 200 && statusCode < 300) {
				NSDictionary *postResponseData =
				[NSJSONSerialization JSONObjectWithData:responseData
												options:NSJSONReadingMutableContainers
												  error:NULL];
				NSLog(@"[SUCCESS!] characters_reserved_per_media is %@", postResponseData[@"characters_reserved_per_media"]);
				
				self.shortURLLength = [postResponseData[@"characters_reserved_per_media"] integerValue];
			}
			else {
				NSLog(@"[ERROR] Server responded: status code %ld %@", statusCode,
					  [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
			}
		}
		else {
			NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
		}
	};
	
	ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
	^(BOOL granted, NSError *error) {
		if (granted) {
			NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
			NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
						  @"/1.1/help/configuration.json"];
			SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
													requestMethod:SLRequestMethodGET
															  URL:url
													   parameters:nil];
			[request setAccount:[accounts lastObject]];
			[request performRequestWithHandler:requestHandler];
		}
		else {
			NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
				  [error localizedDescription]);
		}
	};
	
	[self.accountStore requestAccessToAccountsWithType:twitterType
											   options:NULL
											completion:accountStoreHandler];
	
}


/**
 NSControl delegate
 */
- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector
{
    BOOL result = NO;
    if (commandSelector == @selector(insertNewline:))
    {
        [textView insertNewlineIgnoringFieldEditor:self];
        result = YES;
    }
    return result;
}

@end
