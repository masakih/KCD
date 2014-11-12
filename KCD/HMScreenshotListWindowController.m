//
//  HMScreenshotListWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotListWindowController.h"
#import "HMScreenshotInformation.h"

#import <Quartz/Quartz.h>

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface NSFileManager (KCDExtension)
- (NSString *)_web_pathWithUniqueFilenameForPath:(NSString *)path;
@end


@interface HMScreenshotListWindowController ()
@property (weak, nonatomic) IBOutlet NSArrayController *screenshotsController;
@property (readonly) NSMutableArray *screenshots;

@property (weak) NSSet *selectedIndexes;

@property NSMutableArray *savedScreenshots;

@property (weak, nonatomic) IBOutlet IKImageBrowserView *browser;

// Tweet
@property (strong) ACAccountStore *accountStore;
@property BOOL availableTwitter;
@property NSInteger shortURLLength;

@end

@implementation HMScreenshotListWindowController
@synthesize savedScreenshots = _savedScreenshots;

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_savedScreenshots = [NSMutableArray new];
		
		// Tweet
		_accountStore = [ACAccountStore new];
		
		[self checkShortURLLength];
		
		NSString *tag = NSLocalizedString(@"kancolle", @"kancolle twitter hash tag");
		if(tag) {
			_tagString = [NSString stringWithFormat:@" #%@", tag];
		} else {
			_tagString = @"";
		}
		_appendKanColleTag = HMStandardDefaults.appendKanColleTag;
		
		self.tweetString = @"";
		
		_useMask = HMStandardDefaults.useMask;
	}
	return self;
}

- (void)awakeFromNib
{
	[self.browser setCanControlQuickLookPanel:YES];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
	self.screenshotsController.sortDescriptors = @[sortDescriptor];
	
	[self performSelector:@selector(reloadData:) withObject:nil afterDelay:0.0];
}

- (NSString *)screenshotSaveDirectoryPath
{
	HMAppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
	NSString *parentDirctory = appDelegate.screenShotSaveDirectory;
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSDictionary *localizedInfoDictionary = [mainBundle localizedInfoDictionary];
	NSString *saveDirectoryName = localizedInfoDictionary[@"CFBundleName"];
	NSString *path = [parentDirctory stringByAppendingPathComponent:saveDirectoryName];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	BOOL isDir = NO;
	NSError *error = nil;
	if(![fm fileExistsAtPath:path isDirectory:&isDir]) {
		BOOL ok = [fm createDirectoryAtPath:path
				withIntermediateDirectories:NO
								 attributes:nil
									  error:&error];
		if(!ok) {
			NSLog(@"Can not create screenshot save directory.");
			return parentDirctory;
		}
	} else if(!isDir) {
		NSLog(@"%@ is regular file, not direcory.", path);
		return parentDirctory;
	}
	
	return path;
}

- (NSMutableArray *)screenshots
{
	return self.savedScreenshots;
}
- (void)setScreenshots:(NSMutableArray *)screenshots
{
	self.savedScreenshots = screenshots;
}

- (void)reloadData
{
	NSMutableArray *screenshotNames = [NSMutableArray new];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	NSError *error = nil;
	NSArray *files = [fm contentsOfDirectoryAtPath:self.screenshotSaveDirectoryPath error:&error];
	if(error) {
		NSLog(@"%s: error -> %@", __PRETTY_FUNCTION__, error);
	}
	
	NSArray *imageTypes = [NSImage imageTypes];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	for(NSString *file in files) {
		NSString *fullpath = [self.screenshotSaveDirectoryPath stringByAppendingPathComponent:file];
		NSString *fileType = [ws typeOfFile:fullpath error:NULL];
		if([imageTypes containsObject:fileType]) {
			[screenshotNames addObject:fullpath];
		}
	}
	
	[self willChangeValueForKey:@"screenshots"];
	// 無くなっているものを調べる
	NSMutableArray *deleteObjects = [NSMutableArray new];
	for(HMScreenshotInformation *info in self.screenshots) {
		if(![screenshotNames containsObject:info.path]) {
			[deleteObjects addObject:info];
		}
	}
	[self.savedScreenshots removeObjectsInArray:deleteObjects];
	
	// 新しいものを調べる
	for(NSString *path in screenshotNames) {
		NSUInteger index = [self.screenshots indexOfObjectPassingTest:^(HMScreenshotInformation *obj, NSUInteger idx, BOOL *stop) {
			if([path isEqualToString:obj.path]) {
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		if(index == NSNotFound) {
			HMScreenshotInformation *info = [HMScreenshotInformation new];
			info.path = path;
			[self.savedScreenshots addObject:info];
		}
	}
	[self didChangeValueForKey:@"screenshots"];
	
}

- (IBAction)reloadData:(id)sender
{
	[self reloadData];
}

- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect
{
	NSData *imageData = [image representationUsingType:NSJPEGFileType properties:nil];
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSDictionary *infoList = [mainBundle localizedInfoDictionary];
	NSString *filename = [infoList objectForKey:@"CFBundleName"];
	if([filename length] == 0) {
		filename = @"KCD";
	}
	filename = [filename stringByAppendingPathExtension:@"jpg"];
	NSString *path = [[self screenshotSaveDirectoryPath] stringByAppendingPathComponent:filename];
	path = [[NSFileManager defaultManager] _web_pathWithUniqueFilenameForPath:path];
	
	[imageData writeToFile:path atomically:YES];
	HMScreenshotInformation *info = [HMScreenshotInformation new];
	info.path = path;
	[self.screenshotsController insertObject:info atArrangedObjectIndex:0];
	self.screenshotsController.selectedObjects = @[info];
	[self.window makeKeyAndOrderFront:nil];
}


#pragma mark - Tweet
@synthesize useMask = _useMask;
@synthesize appendKanColleTag = _appendKanColleTag;

+ (NSSet *)keyPathsForValuesAffectingLeaveLength
{
	return [NSSet setWithObjects:@"tweetString", @"appendKanColleTag", nil];
}
+ (NSSet *)keyPathsForValuesAffectingLeaveLengthColor
{
	return [NSSet setWithObject:@"leaveLength"];
}
+ (NSSet *)keyPathsForValuesAffectingCanTweet
{
	return [NSSet setWithObjects:@"leaveLength", @"selectedIndexes", nil];
}

- (BOOL)useMask
{
	return _useMask;
}
- (void)setUseMask:(BOOL)useMask
{
	HMStandardDefaults.useMask = useMask;
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
	HMStandardDefaults.appendKanColleTag = appendKanColleTag;
	_appendKanColleTag = appendKanColleTag;
}
- (BOOL)canTweet
{
	if(self.selectedIndexes.count == 0) {
		return NO;
	}
	
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	if(![twitterType accessGranted]) {
		[self.accountStore requestAccessToAccountsWithType:twitterType
												   options:nil
												completion:^(BOOL granted, NSError *error) {
													if(!granted) {
														NSLog(@"No access granted");
													} else {
														//	NSLog(@"succsess");
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

- (IBAction)tweet:(id)sender
{
	if(self.selectedIndexes.count == 0) {
		NSBeep();
		return;
	}
	NSString *selectionPath = [self.screenshotsController valueForKeyPath:@"selection.path"];
	if(!selectionPath || [selectionPath isEqual:[NSNull null]]) {
		NSBeep();
		return;
	}
	
	NSData *imageData = [NSData dataWithContentsOfFile:selectionPath];
	if(!imageData) {
		NSBeep();
		return;
	}
	
	NSString *status = self.tweetString;
	if(!status) status = @"";
	if(self.appendKanColleTag) {
		status = [status stringByAppendingString:self.tagString];
	}
	
	if(self.leaveLength >= 0) {
		[self postImage:imageData withStatus:status];
		self.tweetString = @"";
	} else {
		NSBeep();
	}
}

- (void)postImage:(NSData *)jpeg withStatus:(NSString *)status
{
	ACAccountType *twitterType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	SLRequestHandler requestHandler =
	^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		if (responseData) {
			NSInteger statusCode = urlResponse.statusCode;
			if (statusCode >= 200 && statusCode < 300) {
				//	NSDictionary *postResponseData =
				//	[NSJSONSerialization JSONObjectWithData:responseData
				//									options:NSJSONReadingMutableContainers
				//									  error:NULL];
				//	NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
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

@end
