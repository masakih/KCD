//
//  HMScreenshotWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/04/06.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotWindowController.h"

#import "HMAppDelegate.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

#import "KCD-Swift.h"

/*
@interface NSFileManager (KCDExtension)
- (NSString *)_web_pathWithUniqueFilenameForPath:(NSString *)path;
@end
 */

@interface HMScreenshotWindowController ()

@property (readonly) NSData *snapData;
@property (strong) NSImage *snap;


@property (strong) ACAccountStore *accountStore;
@property BOOL availableTwitter;
@property NSInteger shortURLLength;


- (void)postImage:(NSData *)jpeg withStatus:(NSString *)status;
@end

@implementation HMScreenshotWindowController
@synthesize snapImageRep = _snapImageRep;
@synthesize snap = _snap;
@synthesize appendKanColleTag = _appendKanColleTag;
@synthesize useMask = _useMask;

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
+ (NSSet *)keyPathsForValuesAffectingCanTweet
{
	return [NSSet setWithObject:@"leaveLength"];
}

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_accountStore = [ACAccountStore new];
		
		[self checkShortURLLength];
		
		NSString *tag = NSLocalizedString(@"kancolle", @"kancolle twitter hash tag");
		if(tag) {
			_tagString = [NSString stringWithFormat:@" #%@", tag];
		} else {
			_tagString = @"";
		}
		_appendKanColleTag = [HMUserDefaults hmStandardDefauls].appendKanColleTag;
		
		self.tweetString = @"";
		
		_useMask = [HMUserDefaults hmStandardDefauls].useMask;
	}
	return self;
}

- (NSBitmapImageRep *)snapImageRep
{
	return _snapImageRep;
}
- (void)setSnapImageRep:(NSBitmapImageRep *)snapImageRep
{
	_snapImageRep = snapImageRep;
	self.snap = nil;
}

- (NSData *)snapData
{
	NSBitmapImageRep *rep = self.snapImageRep;
	
	if(self.useMask) {
		NSImage *image = [[NSImage alloc] initWithSize:[self.snapImageRep size]];
		[image addRepresentation:self.snapImageRep];
		
		[image lockFocus];
		for(HMMaskInformation *info in self.maskSelectView.masks) {
			if(info.enable) {
				NSBezierPath *path = [NSBezierPath bezierPathWithRect:info.maskRect];
				[info.maskColor set];
				[path fill];
			}
		}
		[image unlockFocus];
		
		NSData *tiffData = [image TIFFRepresentation];
		rep = [NSBitmapImageRep imageRepWithData:tiffData];
	}
	
	return [rep representationUsingType:NSJPEGFileType properties:nil];
}
- (NSImage *)snap
{
	if(_snap) return _snap;
	
	NSImage *image = [[NSImage alloc] initWithData:self.snapData];
	_snap = image;
	self.tweetString = @"";
	
	return _snap;
}
- (void)setSnap:(NSImage *)snap
{
	_snap = snap;
}
- (BOOL)useMask
{
	return _useMask;
}
- (void)setUseMask:(BOOL)useMask
{
	[HMUserDefaults hmStandardDefauls].useMask = useMask;
	_useMask = useMask;
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
	[HMUserDefaults hmStandardDefauls].appendKanColleTag = appendKanColleTag;
	_appendKanColleTag = appendKanColleTag;
}
- (BOOL)canTweet
{
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	if(![twitterType accessGranted]) {
		[self.accountStore requestAccessToAccountsWithType:twitterType
												   options:nil
												completion:^(BOOL granted, NSError *error) {
													if(!granted) {
														NSLog(@"No access granted");
													} else {
//														NSLog(@"succsess");
													}
												}];
	}
	NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
	if([accounts count] == 0) {
		NSLog(@"twitter account not avail.");
		NSLog(@"Accounts -> %@", self.accountStore.accounts);
		return NO;
	}
	self.availableTwitter = YES;
	
	return self.availableTwitter && self.leaveLength >= 0;
}
- (BOOL)canSave
{
	return self.snapData ? YES : NO;
}

- (NSURL *)saveDirectoryURL
{
    HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	return [NSURL fileURLWithPath:appDelegate.screenShotSaveDirectory];
}

- (IBAction)tweet:(id)sender
{
	if(!self.snapData) {
		NSBeep();
		return;
	}
	
	NSString *status = self.tweetString;
	if(!status) status = @"";
	if(self.appendKanColleTag) {
		status = [status stringByAppendingString:self.tagString];
	}
	
	if(self.leaveLength >= 0) {
		[self postImage:self.snapData withStatus:status];
		[self.window.sheetParent endSheet:self.window returnCode:NSOKButton + 1];
	} else {
		NSBeep();
	}
}

- (IBAction)saveSnap:(id)sender
{
	[self.window.sheetParent endSheet:self.window returnCode:NSOKButton + 0];
	
	if(!self.snapData) return;
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSDictionary *infoList = [mainBundle localizedInfoDictionary];
	NSString *filename = [infoList objectForKey:@"CFBundleName"];
	if([filename length] == 0) {
		filename = @"KCD";
	}
	filename = [filename stringByAppendingPathExtension:@"jpg"];
	NSURL *path = [[self saveDirectoryURL] URLByAppendingPathComponent:filename];
	
	filename = [[NSFileManager defaultManager] _web_pathWithUniqueFilenameForPath:[path path]];
	
	[self.snapData writeToFile:filename atomically:YES];
}
- (IBAction)cancel:(id)sender
{
	[self.window.sheetParent endSheet:self.window returnCode:NSCancelButton];
}
- (void)postImage:(NSData *)jpeg withStatus:(NSString *)status
{
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	SLRequestHandler requestHandler =
	^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		if (responseData) {
			NSInteger statusCode = urlResponse.statusCode;
			if (statusCode >= 200 && statusCode < 300) {
//				NSDictionary *postResponseData =
//				[NSJSONSerialization JSONObjectWithData:responseData
//												options:NSJSONReadingMutableContainers
//												  error:NULL];
//				NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
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
//				NSLog(@"[SUCCESS!] characters_reserved_per_media is %@", postResponseData[@"characters_reserved_per_media"]);
				
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

/**
 *  NSWindow delegate
 */
- (void)windowWillClose:(NSNotification *)notification
{
	[self.maskSelectView disableAllMasks:self];
}

@end
