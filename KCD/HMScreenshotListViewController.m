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

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"

#import <Quartz/Quartz.h>

@interface NSFileManager (KCDExtension)
- (NSString *)_web_pathWithUniqueFilenameForPath:(NSString *)path;
@end

@interface HMCacheVersionInfo : NSObject <NSCopying>
@property (copy) NSString *fullpath;
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


@interface HMScreenshotListViewController () <NSScrubberDataSource, NSScrubberDelegate>

@property (nonatomic, weak) IBOutlet NSArrayController *screenshotsController;
@property (strong) NSMutableArray *deletedPaths;

@property (nonatomic, weak) IBOutlet NSCollectionView *collectionView;
@property (nonatomic, strong) IBOutlet NSMenu *contextMenu;
@property (nonatomic, weak) IBOutlet NSButton *shareButton;


@property (nonatomic, weak) IBOutlet NSView *standardView;
@property (nonatomic, weak) IBOutlet NSView *editorView;

@property (nonatomic) CGFloat zoom;
@property CGFloat maxZoom;

@property (nonatomic, strong) IBOutlet NSTouchBar *screenshotTouchBar;
@property (nonatomic, weak) IBOutlet NSScrubber *scrubber;
@property (nonatomic, strong) NSSharingServicePickerTouchBarItem *sharingItem;

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

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _screenshots = [HMScreenshotModel new];
        _screenshots.screenshots = [self loadCache];
        _deletedPaths = [NSMutableArray new];
        
        _zoom = 0.3;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"HMScreenshotCollectionViewItem" bundle:nil];
    [self.collectionView registerClass:[NSCollectionViewItem class] forItemWithIdentifier:@"item"];
    [self.collectionView registerNib:nib forItemWithIdentifier:@"item"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO];
    self.screenshots.sortDescriptors = @[sortDescriptor];
    
    [self.collectionView addObserver:self
                          forKeyPath:@"selectionIndexPaths"
                             options:0
                             context:nil];
    self.collectionView.postsFrameChangedNotifications = YES;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(viewFrameDidChange:)
               name:NSViewFrameDidChangeNotification
             object:self.collectionView];
    [self viewFrameDidChange:nil];
    
    [nc addObserver:self
           selector:@selector(scrollViewDidLiveScrollNotification:)
               name:NSScrollViewDidLiveScrollNotification
             object:self.collectionView.enclosingScrollView];
    
	
	[self performSelector:@selector(reloadData:)
			   withObject:nil
			   afterDelay:0.0];
}

const CGFloat def = 800;
const CGFloat leftMergin = 8 + 1;
const CGFloat rightMergin = 8 + 1;

CGFloat maxZoom(CGFloat width) {
    width -= leftMergin;
    width -= rightMergin;
    
    if(width < 240) {
        return width / def / 0.6;
    }
    if(width > 800) {
        return 1;
    }
    return pow((width / def - 0.2) / 0.8, 1.0 / 3.0);
}
CGFloat realFromZoom(CGFloat zoom) {
    CGFloat f = 0.0;
    
    if(zoom < 0.5) {
        f = def * zoom * 0.6;
    } else {
        f = def * (0.8 * zoom * zoom * zoom + 0.2);
    }
    
    return f;
}
- (void)setZoom:(CGFloat)zoom
{
    _zoom = zoom;
    [self.collectionView reloadData];
}
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat f = realFromZoom(self.zoom);
    return NSMakeSize(f, f);
}
- (void)viewFrameDidChange:(id)no
{
    self.maxZoom = maxZoom(self.collectionView.frame.size.width);;
    
    CGFloat f = self.maxZoom;
    if(_zoom > f) self.zoom = f;
}

- (void)scrollViewDidLiveScrollNotification:(NSNotification *)notification
{
    NSSet<NSIndexPath *> *visibleItems = self.collectionView.indexPathsForVisibleItems;
    NSIndexPath *index = visibleItems.allObjects.firstObject;
    NSInteger middle = index.item + visibleItems.count / 2;
    if(middle < [self.screenshotsController.arrangedObjects count] - 1) {
        [self.scrubber scrollItemAtIndex:middle toAlignment:NSScrubberAlignmentNone];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if( object == self.collectionView ) {
        NSSet<NSIndexPath *> *selections = self.collectionView.selectionIndexPaths;
        NSMutableIndexSet *selectionIndexes = [NSMutableIndexSet indexSet];
        for(NSIndexPath *indexPath in selections) {
            [selectionIndexes addIndex:[indexPath indexAtPosition:1]];
        }
        self.screenshots.selectedIndexes = selectionIndexes;
        self.scrubber.selectedIndex = selectionIndexes.firstIndex;
        
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (NSString *)screenshotSaveDirectoryPath
{
	HMAppDelegate *appDelegate =[[NSApplication sharedApplication] delegate];
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

- (void)registerScreenshot:(NSBitmapImageRep *)image fromOnScreen:(NSRect)screenRect
{
    if( !image ) return;
    
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
            NSSet *set = [NSSet setWithObject:[NSIndexPath indexPathForItem:0 inSection:0]];
            self.collectionView.selectionIndexPaths = set;
            
            [self.collectionView scrollToItemsAtIndexPaths:set
                                            scrollPosition:NSCollectionViewScrollPositionNearestHorizontalEdge];
			
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
    NSSet *set = [NSSet setWithObject:[NSIndexPath indexPathForItem:0 inSection:0]];
    self.collectionView.selectionIndexPaths = set;
	
    [self.scrubber reloadData];
    
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
    NSSet *set = [NSSet setWithObject:[NSIndexPath indexPathForItem:selectionIndex inSection:0]];
    self.collectionView.selectionIndexPaths = set;
    
    [self.scrubber reloadData];
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
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:image.TIFFRepresentation];
    [self registerScreenshot:imageRep fromOnScreen:NSZeroRect];
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

#pragma mark  NSTouchBarProvider & NSTouchBarDelegate
static NSTouchBarItemIdentifier ServicesItemIdentifier = @"com.masakih.sharingTouchBarItem";
- (NSTouchBar *)makeTouchBar
{
    NSArray *array = nil;
    NSBundle *mainBundle = [NSBundle mainBundle];
    [mainBundle loadNibNamed:@"HMScreenshotTouchBar"
                       owner:self
             topLevelObjects:&array];
        
    NSMutableArray *identifires = [self.screenshotTouchBar.defaultItemIdentifiers mutableCopy];
    [identifires addObject:ServicesItemIdentifier];
    self.screenshotTouchBar.defaultItemIdentifiers = identifires;
    
    return self.screenshotTouchBar;
}
- (nullable NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
{
    if([identifier isEqualToString:ServicesItemIdentifier]){
        if (self.sharingItem == nil) {
            _sharingItem = [[NSSharingServicePickerTouchBarItem alloc] initWithIdentifier:identifier];
            id<NSSharingServicePickerTouchBarItemDelegate> w = self.view.window.windowController;
            if([w conformsToProtocol:@protocol(NSSharingServicePickerTouchBarItemDelegate)]) {
                self.sharingItem.delegate = w;
            }
        }
        return self.sharingItem;
    }
    
    return nil;
}

#pragma mark NSScrubberDataSource and NSScrubberDelegate
- (NSInteger)numberOfItemsForScrubber:(NSScrubber *)scrubber
{
    return [self.screenshotsController.arrangedObjects count];
}
- (__kindof NSScrubberItemView *)scrubber:(NSScrubber *)scrubber viewForItemAtIndex:(NSInteger)index
{
    HMScreenshotInformation *info = [self.screenshotsController.arrangedObjects objectAtIndex:index];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:info.path];
    NSScrubberImageItemView *itemView = [NSScrubberImageItemView new];
    itemView.image = image;
    
    return itemView;
}
- (void)scrubber:(NSScrubber *)scrubber didSelectItemAtIndex:(NSInteger)selectedIndex
{
    NSSet *set = [NSSet setWithObject:[NSIndexPath indexPathForItem:selectedIndex inSection:0]];
    self.collectionView.selectionIndexPaths = set;
}
- (void)scrubber:(NSScrubber *)scrubber didChangeVisibleRange:(NSRange)visibleRange
{
    
    NSInteger centerIndex = visibleRange.location + visibleRange.length / 2;
    NSSet<NSIndexPath *> *set = [NSSet setWithObject:[NSIndexPath indexPathForItem:centerIndex inSection:0]];
//    [[self.collectionView animator] scrollToItemsAtIndexPaths:set scrollPosition:NSCollectionViewScrollPositionCenteredVertically];
    [self.collectionView scrollToItemsAtIndexPaths:set scrollPosition:NSCollectionViewScrollPositionCenteredVertically];
}

@end
