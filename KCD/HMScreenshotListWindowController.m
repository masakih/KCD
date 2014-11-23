//
//  HMScreenshotListWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2014/11/03.
//  Copyright (c) 2014年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotListWindowController.h"
#import "HMScreenshotInformation.h"
#import "HMMaskSelectView.h"

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

@property (weak) NSIndexSet *selectedIndexes;

@property NSMutableArray *savedScreenshots;

@property (weak, nonatomic) IBOutlet IKImageBrowserView *browser;
@property (weak, nonatomic) IBOutlet NSMenu *contextMenu;
@property (weak, nonatomic) IBOutlet NSButton *shareButton;

@end

@interface HMScreenshotListWindowController (HMSharingService) <NSSharingServiceDelegate, NSSharingServicePickerDelegate>

@end

@implementation HMScreenshotListWindowController
@synthesize savedScreenshots = _savedScreenshots;

- (id)init
{
	self = [super initWithWindowNibName:NSStringFromClass([self class])];
	if(self) {
		_savedScreenshots = [NSMutableArray new];
		
		
		NSString *tag = NSLocalizedString(@"kancolle", @"kancolle twitter hash tag");
		if(tag) {
			_tagString = [NSString stringWithFormat:@" #%@", tag];
		} else {
			_tagString = @"";
		}
		_appendKanColleTag = HMStandardDefaults.appendKanColleTag;
		
		_useMask = HMStandardDefaults.useMask;
		
		[self reloadData];
	}
	return self;
}

- (void)awakeFromNib
{
	[self.browser setCanControlQuickLookPanel:YES];
	[self.shareButton sendActionOn:NSLeftMouseDownMask];
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
	self.screenshotsController.sortDescriptors = @[sortDescriptor];
	
	[self prepareScreenshot:nil];
//	[self performSelector:@selector(prepareScreenshot:) withObject:nil afterDelay:0.0];
	
}
- (void)prepareScreenshot:(id)dummy
{
	[self reloadData];
	[self.screenshotsController rearrangeObjects];
	[self.browser reloadData];
	
	self.selectedIndexes = [NSIndexSet indexSetWithIndex:0];
//	[self performSelector:@selector(setSelectedIndexes:) withObject:[NSIndexSet indexSetWithIndex:0] afterDelay:0.0];
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
- (IBAction)delete:(id)sender
{
	NSString *imagePath = [self.screenshotsController valueForKeyPath:@"selection.path"];	
	NSString *scriptTmplate =
	@"tell application \"Finder\"\n"
	@"	move ( \"%@\" as POSIX file) to trash\n"
	@"end tell";
	NSString *script = [NSString stringWithFormat:scriptTmplate, imagePath];
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
	if(!appleScript) NSBeep();
	[appleScript executeAndReturnError:nil];
	
	[self reloadData:nil];
}
- (IBAction)revealInFinder:(id)sender
{
	NSString *imagePath = [self.screenshotsController valueForKeyPath:@"selection.path"];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws selectFile:imagePath inFileViewerRootedAtPath:@""];
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
	
	if(HMStandardDefaults.showsListWindowAtScreenshot) {
		[self.window makeKeyAndOrderFront:nil];
	}
}


#pragma mark - Tweet
@synthesize useMask = _useMask;
@synthesize appendKanColleTag = _appendKanColleTag;


- (BOOL)useMask
{
	return _useMask;
}
- (void)setUseMask:(BOOL)useMask
{
	HMStandardDefaults.useMask = useMask;
	_useMask = useMask;
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

- (IBAction)share:(id)sender
{
	NSString *imagePath = [self.screenshotsController valueForKeyPath:@"selection.path"];
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
	
	NSString *tags = nil;
	if(self.appendKanColleTag) {
		tags = self.tagString;
		tags = [@" \n" stringByAppendingString:tags];
	}
	NSArray *items = [NSArray arrayWithObjects:image, tags, nil];
	NSSharingServicePicker *picker = [[NSSharingServicePicker alloc] initWithItems:items];
	picker.delegate = self;
	[picker showRelativeToRect:[sender bounds]
						ofView:sender
				 preferredEdge:NSMinXEdge];
}


#pragma mark-## IKImageBrowserDelegate
- (void) imageBrowser:(IKImageBrowserView *) aBrowser cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *) event
{
	[NSMenu popUpContextMenu:self.contextMenu withEvent:event forView:aBrowser];
}


#pragma mark-## NSSharingServiceDelegate NSSharingServicePickerDelegate
- (id <NSSharingServiceDelegate>)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker delegateForSharingService:(NSSharingService *)sharingService
{
	return self;
}

- (NSRect)sharingService:(NSSharingService *)sharingService sourceFrameOnScreenForShareItem:(id<NSPasteboardWriting>)item
{
	if([item isKindOfClass:[NSString class]]) return NSZeroRect;
	
	NSRect frame = self.maskSelectView.frame;
	return [self.window convertRectToScreen:frame];
}
- (NSImage *)sharingService:(NSSharingService *)sharingService transitionImageForShareItem:(id<NSPasteboardWriting>)item contentRect:(NSRect *)contentRect
{
	if([item isKindOfClass:[NSImage class]]) return (NSImage *)item;
	
	return nil;
}
- (NSWindow *)sharingService:(NSSharingService *)sharingService sourceWindowForShareItems:(NSArray *)items sharingContentScope:(NSSharingContentScope *)sharingContentScope
{
	return self.window;
}


@end
