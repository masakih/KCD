//
//  ViewController.m
//  testScreenshotForKCD
//
//  Created by Hori,Masaki on 2016/03/27.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMScreenshotListViewController.h"

#import "HMScreenshotModel.h"
#import "HMScreenshotInformation.h"

#import "HMUserDefaults.h"

#import <Quartz/Quartz.h>

@interface NSFileManager (KCDExtension)
- (NSString *)_web_pathWithUniqueFilenameForPath:(NSString *)path;
@end

@interface HMCacheVersionInfo : NSObject <NSCopying>
@property (strong) NSString *fullpath;
@property (strong) NSNumber *version;
@end

@implementation HMCacheVersionInfo

- (instancetype)copyWithZone:(NSZone *)zone
{
	HMCacheVersionInfo *result = [[self class] new];
	result.fullpath = self.fullpath;
	result.version = self.version;
	return result;
}
- (NSUInteger)hash
{
	return [self.fullpath hash];
}
- (BOOL)isEqual:(id)object
{
	if([super isEqual:object]) return YES;
	if(![object isMemberOfClass:[self class]]) return NO;
	return [self.fullpath isEqualToString:[object fullpath]];
}
@end


@interface HMScreenshotListViewController () <NSSplitViewDelegate>

@property (weak, nonatomic) IBOutlet NSArrayController *screenshotsController;
@property (strong) NSMutableArray *deletedPaths;

@property (weak, nonatomic) IBOutlet IKImageBrowserView *browser;
@property (strong, nonatomic) IBOutlet NSMenu *contextMenu;
@property (weak, nonatomic) IBOutlet NSButton *shareButton;


@property (weak, nonatomic) IBOutlet NSView *standardView;
@property (weak, nonatomic) IBOutlet NSView *editorView;

- (void)reloadData;

@end

@implementation HMScreenshotListViewController

- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super initWithCoder:coder];
	if(self) {
		_screenshots = [HMScreenshotModel new];
		_screenshots.screenshots = [self loadCache];
		_deletedPaths = [NSMutableArray new];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.browser setCanControlQuickLookPanel:YES];

	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
	self.screenshots.sortDescriptors = @[sortDescriptor];
	self.screenshots.selectedIndexes = [NSIndexSet indexSetWithIndex:0];
	
	[self performSelector:@selector(reloadData:)
			   withObject:nil
			   afterDelay:0.0];
}

- (NSString *)screenshotSaveDirectoryPath
{
#warning MUST MODIFY
	NSString *parentDirctory = [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
	
	NSString *path = [parentDirctory stringByAppendingPathComponent:@"艦娘は今日も元気です。"];
	
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

- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect
{
	dispatch_queue_t queue = dispatch_queue_create("Screenshot queue", DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		NSData *imageData = [image representationUsingType:NSJPEGFileType properties:@{}];
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSDictionary *infoList = [mainBundle localizedInfoDictionary];
		NSString *filename = [infoList objectForKey:@"CFBundleName"];
		if([filename length] == 0) {
			filename = @"KCD";
		}
		filename = [filename stringByAppendingPathExtension:@"jpg"];
		NSString *path = [[self screenshotSaveDirectoryPath] stringByAppendingPathComponent:filename];
		path = [[NSFileManager defaultManager] _web_pathWithUniqueFilenameForPath:path];
		[imageData writeToFile:path atomically:NO];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			HMScreenshotInformation *info = [HMScreenshotInformation new];
			info.path = path;
			info.version = [self cacheVersionForPath:path];
			
			[self.screenshotsController insertObject:info atArrangedObjectIndex:0];
			self.screenshotsController.selectedObjects = @[info];
			
			if(HMStandardDefaults.showsListWindowAtScreenshot) {
				[self.view.window makeKeyAndOrderFront:nil];
			}
			[self saveCache];
		});
	});
}

- (void)reloadData
{
	NSMutableArray *screenshotNames = [NSMutableArray new];
	NSMutableArray *currentArray = [self.screenshots.screenshots mutableCopy];
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
	
	// 無くなっているものを調べる
	NSMutableArray *deleteObjects = [NSMutableArray new];
	for(HMScreenshotInformation *info in self.screenshots.screenshots) {
		if(![screenshotNames containsObject:info.path]) {
			[self incrementCacheVersionForPath:info.path];
			[deleteObjects addObject:info];
		}
	}
	[currentArray removeObjectsInArray:deleteObjects];
	
	// 新しいものを調べる
	for(NSString *path in screenshotNames) {
		NSUInteger index = [self.screenshots.screenshots indexOfObjectPassingTest:^(HMScreenshotInformation *obj, NSUInteger idx, BOOL *stop) {
			if([path isEqualToString:obj.path]) {
				*stop = YES;
				return YES;
			}
			return NO;
		}];
		if(index == NSNotFound) {
			HMScreenshotInformation *info = [HMScreenshotInformation new];
			info.path = path;
			[currentArray addObject:info];
		}
	}
	self.screenshots.screenshots = [currentArray copy];
	self.screenshots.selectedIndexes = [NSIndexSet indexSetWithIndex:0];
	
	[self saveCache];
}

- (void)saveCache
{
	NSString *path = [self screenshotSaveDirectoryPath];
	path = [path stringByAppendingPathComponent:@"Cache.db"];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.screenshots.screenshots];
	NSError *error = nil;
	BOOL ok = [data writeToURL:url
					   options:NSDataWritingAtomic
						 error:&error];
	if(!ok) {
		if(error) {
			[[NSApplication sharedApplication] presentError:error];
		}
		NSLog(@"Can not write error. %@", error);
	}
}

- (NSArray *)loadCache
{
	NSString *path = [self screenshotSaveDirectoryPath];
	path = [path stringByAppendingPathComponent:@"Cache.db"];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	NSData *data = [NSData dataWithContentsOfURL:url];
	if(!data) return [NSArray new];
	
	id loaded = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if(![loaded isKindOfClass:[NSArray class]]) {
		return [NSArray new];
	}
	
	return loaded;
}

- (IBAction)reloadData:(id)sender
{
	[self reloadData];
}

- (IBAction)delete:(id)sender
{
	NSArray<HMScreenshotInformation *> *informations = [self.screenshotsController.selectedObjects copy];
	NSMutableArray<NSString *> *paths = [NSMutableArray array];
	for(HMScreenshotInformation *info in informations) {
		[paths addObject:info.path];
	}
	NSMutableArray<NSString *> *opsixPathes = [NSMutableArray array];
	for(NSString *path in paths) {
		[opsixPathes addObject:[NSString stringWithFormat:@"(\"%@\" as POSIX file)", path]];
	}
	NSString *pathListString = [opsixPathes componentsJoinedByString:@" , "];
	pathListString = [@"{ " stringByAppendingString:pathListString];
	pathListString = [pathListString stringByAppendingString:@" }"];
	
	NSString *scriptTmplate =
	@"tell application \"Finder\"\n"
	@"	delete  %@\n"
	@"end tell";
	NSString *script = [NSString stringWithFormat:scriptTmplate, pathListString];
	NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
	if(!appleScript) NSBeep();
	[appleScript executeAndReturnError:nil];
	
	NSIndexSet *selectionIndexes = self.screenshotsController.selectionIndexes;
	[self.screenshotsController removeObjectsAtArrangedObjectIndexes:selectionIndexes];
	for(NSString *path in paths) {
		[self incrementCacheVersionForPath:path];
	}
	[self saveCache];
	
	NSInteger selectionIndex = selectionIndexes.firstIndex;
	NSUInteger count = [self.screenshotsController.arrangedObjects count];
	if(count == 0) return;
	if(count <= selectionIndex) {
		selectionIndex = count - 1;
	}
	self.screenshotsController.selectionIndex = selectionIndex;
}
- (IBAction)revealInFinder:(id)sender
{
	NSArray<HMScreenshotInformation *> *informations = [self.screenshotsController.selectedObjects copy];
	NSMutableArray<NSString *> *paths = [NSMutableArray array];
	for(HMScreenshotInformation *info in informations) {
		[paths addObject:info.path];
	}
	NSMutableArray<NSURL *> *pathURLs = [NSMutableArray array];
	for(NSString *path in paths) {
		[pathURLs addObject:[NSURL fileURLWithPath:path]];
	}
	
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	[ws activateFileViewerSelectingURLs:pathURLs];
}

- (IBAction)registerImage:(id)sender
{
	if(![sender respondsToSelector:@selector(image)]) return;
	
	NSImage *image = [sender image];
	
	dispatch_queue_t queue = dispatch_queue_create("Screenshot queue", DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation];
		NSData *imageData = [imageRep representationUsingType:NSJPEGFileType properties:@{}];
		
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSDictionary *infoList = [mainBundle localizedInfoDictionary];
		NSString *filename = [infoList objectForKey:@"CFBundleName"];
		if([filename length] == 0) {
			filename = @"KCD";
		}
		filename = [filename stringByAppendingPathExtension:@"jpg"];
		NSString *path = [[self screenshotSaveDirectoryPath] stringByAppendingPathComponent:filename];
		path = [[NSFileManager defaultManager] _web_pathWithUniqueFilenameForPath:path];
		[imageData writeToFile:path atomically:NO];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			HMScreenshotInformation *info = [HMScreenshotInformation new];
			info.path = path;
			info.version = [self cacheVersionForPath:path];
			
			[self.screenshotsController insertObject:info atArrangedObjectIndex:0];
			self.screenshotsController.selectedObjects = @[info];
			
			if(HMStandardDefaults.showsListWindowAtScreenshot) {
				[self.view.window makeKeyAndOrderFront:nil];
			}
			[self saveCache];
		});
	});
}

- (void)incrementCacheVersionForPath:(NSString *)fullpath
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullpath = %@", fullpath];
	NSArray *filteredArray = [self.deletedPaths filteredArrayUsingPredicate:predicate];
	if(filteredArray.count == 0) {
		HMCacheVersionInfo *info = [HMCacheVersionInfo new];
		info.fullpath = fullpath;
		info.version = @(1);
		[self.deletedPaths addObject:info];
	} else {
		HMCacheVersionInfo *info = filteredArray[0];
		info.version = @(info.version.unsignedIntegerValue + 1);
	}
}
- (NSUInteger)cacheVersionForPath:(NSString *)fullpath
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullpath = %@", fullpath];
	NSArray *filteredArray = [self.deletedPaths filteredArrayUsingPredicate:predicate];
	if(filteredArray.count == 0) {
		return 0;
	}
	
	HMCacheVersionInfo *cacheInfo = filteredArray[0];
	return cacheInfo.version.unsignedIntegerValue;
}


- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(nullable id)sender
{
	NSViewController *v = segue.destinationController;
	v.representedObject = self.screenshots;
}

#pragma mark - NSSplitViewDelegate

const CGFloat leftMinWidth = 300;
const CGFloat rightMinWidth = 400;

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
	if(dividerIndex == 0) {
		return leftMinWidth;
	}
	return proposedMinimumPosition;
}
- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
	if(dividerIndex == 0) {
		NSSize size = splitView.frame.size;
		CGFloat rightWidth = size.width - proposedPosition;
		if(rightWidth < rightMinWidth) {
			return size.width - rightMinWidth;
		}
	}
	return proposedPosition;
}
- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
	[splitView adjustSubviews];
	
	NSView *leftView = splitView.subviews[0];
	NSView *rightView = splitView.subviews[1];
	
	if(NSWidth(leftView.frame) < leftMinWidth) {
		NSRect leftRect = leftView.frame;
		leftRect.size.width = leftMinWidth;
		leftView.frame = leftRect;
		
		NSRect rightRect = rightView.frame;
		rightRect.size.width = NSWidth(splitView.frame) - NSWidth(leftRect) - splitView.dividerThickness;
		rightRect.origin.x = NSWidth(leftRect) + splitView.dividerThickness;
		rightView.frame = rightRect;
	}
}
- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
	NSView *leftView = splitView.subviews[0];
	NSView *rightView = splitView.subviews[1];
	
	if(leftView == view) {
		if(NSWidth(leftView.frame) < leftMinWidth) return NO;
	}
	if(rightView == view) {
		if(NSWidth(leftView.frame) >= leftMinWidth) return NO;
	}
	
	return YES;
}


#pragma mark - IKImageBrowserDelegate
- (void)imageBrowser:(IKImageBrowserView *) aBrowser cellWasRightClickedAtIndex:(NSUInteger) index withEvent:(NSEvent *) event
{
	[NSMenu popUpContextMenu:self.contextMenu withEvent:event forView:aBrowser];
}

@end
